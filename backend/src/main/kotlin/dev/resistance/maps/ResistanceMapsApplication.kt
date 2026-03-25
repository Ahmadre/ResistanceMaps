package dev.resistance.maps

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@EnableScheduling
class ResistanceMapsApplication

fun main(args: Array<String>) {
    runApplication<ResistanceMapsApplication>(*args)
}
