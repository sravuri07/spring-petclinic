# Simple Dockerfile for personal/development use
FROM eclipse-temurin:17-jdk-alpine

# Install curl for health checks (optional)
RUN apk add --no-cache curl

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn
COPY pom.xml .

# Make mvnw executable
RUN chmod +x mvnw

# Copy source code
COPY src src

# Download dependencies and build
RUN ./mvnw clean package -DskipTests

# Expose port
EXPOSE 8080

# Run the application directly
CMD ["java", "-jar", "target/*.jar"]
