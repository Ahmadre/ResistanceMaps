# Build stage using Gradle image (no wrapper files required)
FROM gradle:8.7-jdk21 AS build
WORKDIR /app
COPY settings.gradle.kts build.gradle.kts /app/
COPY src /app/src
ENV JAVA_TOOLCHAIN_VERSION=21
RUN gradle --no-daemon clean bootJar -x test

# Run stage
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
