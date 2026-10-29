
# ==========================================
# Stage 1: Build the Spring Boot Application
# ==========================================

FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy Maven configuration
COPY pom.xml .

# Download project dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Compile and package the application
RUN mvn clean verify


# ==========================================
# Stage 2: Optimized Runtime
# ==========================================

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Copy the JAR from the build stage
COPY --from=build --chown=appuser:appgroup /app/target/*.jar app.jar

# Run as non-root user
USER appuser

# Spring Boot port
EXPOSE 8080

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]

