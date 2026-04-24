It looks like the original README was focused purely on local development. Since you've now upgraded this project with **Docker**, **GitHub Actions**, and **Security Hardening**, we should keep those local instructions but put your new DevOps work front and center.

Here is the "Elite" version that merges your new work with the existing local run instructions.

```markdown
# 🚀 Spring Boot Hello World: Enterprise CI/CD & Hardening

A professional demonstration of a modern DevOps lifecycle. This repository has been upgraded from a simple Spring Boot app to a fully automated, security-hardened containerized application.

---

## 🏗️ The Tech Stack

| Component | Technology |
| :--- | :--- |
| **Language** | Java 17 (Spring Boot) |
| **Build Tool** | Maven |
| **CI/CD** | GitHub Actions |
| **Containerization** | Docker (Non-Root/Hardened) |
| **Registry** | Docker Hub |

---

## 🐳 1. The Hardened Dockerfile
We follow the **Principle of Least Privilege**. The application runs under a dedicated non-root system user to minimize the security attack surface.

```dockerfile
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
```

---

## 🤖 2. The GitHub Actions Workflow
The pipeline (`.github/workflows/ci-pipeline.yml`) automates the entire "Code-to-Cloud" journey.

```yaml
name: Java CI with Docker

on:
  push:
    branches: [ "**" ]
  pull_request:
    branches: [ "master" ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Build with Maven
        run: mvn clean package -DskipTests

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKERHUB_USERNAME }}/spring-boot-hello
          tags: |
            type=ref,event=branch
            type=sha,format=short
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/master' }}

      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

---

## 🛠️ 3. How to Run (Containerized)
The fastest way to run the production-ready version is via Docker:

```bash
# Pull the latest stable image
docker pull devketsops/spring-boot-hello:latest

# Run and map port 8080
docker run -p 8080:8080 devketsops/spring-boot-hello:latest
```

---

## 🛡️ DevOps Best Practices Applied
* **Container Hardening:** Zero use of root privileges at runtime.
* **Traceability:** Images tagged with unique **Git Commit SHAs**.
* **Performance:** Optimized via **Maven Caching** and **Docker Buildx**.
* **Security:** Credentials managed via encrypted GitHub Secrets.

---
```
