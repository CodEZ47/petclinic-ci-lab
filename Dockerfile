# ---------- Stage 1: Build the application ----------
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -Dcheckstyle.skip

# ---------- Stage 2: Run the app ----------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 1️⃣ Install MySQL JDBC driver if not bundled in the JAR
RUN apk add --no-cache curl && \
    curl -L -o mysql-connector.jar https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar

# 2️⃣ Create a non-root user
RUN addgroup -S akebede && adduser -S akebede -G akebede
USER akebede

# 3️⃣ Copy the built JAR
COPY --from=builder /app/target/*.jar app.jar

# 4️⃣ Expose the app port
EXPOSE 8080

# 5️⃣ Run with MySQL profile active (forces correct driver + properties)
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=mysql,spring-data-jpa"]
