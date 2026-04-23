# Use a lightweight JDK 17 image
FROM eclipse-temurin:17-jre-alpine

# 1. Create a system group and user
# -S creates a system user/group
# -G adds the user to the group
RUN addgroup -S spring && adduser -S spring -G spring

# 2. Create the app directory and set ownership
WORKDIR /app
RUN chown spring:spring /app

# 3. Switch to the non-root user
USER spring

# 4. Copy the JAR file
# Use --chown to ensure the 'spring' user owns the file, not root
COPY --chown=spring:spring target/*.jar app.jar

# Spring Boot default port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
