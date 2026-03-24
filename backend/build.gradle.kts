import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("org.springframework.boot") version "3.4.3"
    id("io.spring.dependency-management") version "1.1.7"
    kotlin("jvm") version "2.1.20"
    kotlin("plugin.spring") version "2.1.20"
}

group = "dev.resistance"
version = "0.1.0"
java.sourceCompatibility = JavaVersion.VERSION_23

val toolchainVersion = (System.getenv("JAVA_TOOLCHAIN_VERSION") ?: "23").toInt()

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(toolchainVersion))
    }
}

kotlin {
    jvmToolchain(toolchainVersion)
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // Security - Resource Server (JWT from Keycloak)
    implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
    implementation("org.springframework.boot:spring-boot-starter-security")

    // Mongo
    implementation("org.springframework.boot:spring-boot-starter-data-mongodb")

    // RabbitMQ
    implementation("org.springframework.boot:spring-boot-starter-amqp")

    // Kotlin
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    compilerOptions {
        freeCompilerArgs.add("-Xjsr305=strict")
        jvmTarget.set(JvmTarget.JVM_23)
    }
}
