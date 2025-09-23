# Sử dụng image base cho Java
FROM openjdk:17-jdk-slim

# Đặt thư mục làm việc
WORKDIR /app

# Copy file JAR đã build vào container
COPY target/phonestore-0.0.1-SNAPSHOT.jar app.jar

# Expose cổng ứng dụng
EXPOSE 8080

# Lệnh chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]