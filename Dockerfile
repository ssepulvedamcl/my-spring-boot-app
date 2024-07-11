# Usar la imagen base de OpenJDK 11
FROM openjdk:11-jre-slim

# Establecer el directorio de trabajo en /app
WORKDIR /app

# Copiar el archivo JAR de la aplicación al contenedor Docker
COPY target/my-spring-boot-app-1.0-SNAPSHOT.jar /app/my-spring-boot-app.jar

# Exponer el puerto en el que se ejecutará la aplicación
EXPOSE 8080

# Ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "/app/my-spring-boot-app.jar"]
