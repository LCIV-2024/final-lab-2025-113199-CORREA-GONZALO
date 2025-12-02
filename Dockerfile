# ================================
# STAGE 1: Build (Maven)
# ================================
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# ================================
# STAGE 2: Runtime
# ================================
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN apk add --no-cache curl
COPY --from=builder /app/target/demobase-0.0.1-SNAPSHOT.jar app.jar
ARG PORT=8080
ENV SERVER_PORT=${PORT}
EXPOSE ${PORT}
ENV JAVA_OPTS="-Xms128m -Xmx512m"

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:${SERVER_PORT}/api/players || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
