# STAGE 1: Build (The "Kitchen")
# We use a full Maven image to compile the code
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /build

# Copy only the files needed for the build
COPY pom.xml .
COPY src ./src

# Compile and package the JAR
RUN mvn clean package -DskipTests

# STAGE 2: Run (The "Serving Table")
# We switch to a tiny JRE image for the actual runtime
FROM eclipse-temurin:17-jre-alpine

# 1. Security: Create a system user with no shell access
RUN addgroup -S spring && \
    adduser -S -s /sbin/nologin -G spring spring

# 2. Set the working directory
WORKDIR /app

# 3. Security: Copy ONLY the JAR from the build stage
# We use --from=build to grab the file from the previous stage
COPY --from=build --chown=spring:spring /build/target/*.jar app.jar

# 4. Privilege Drop: Switch to the non-root user
USER spring

# Spring Boot default port
EXPOSE 8080

# 5. Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
