package dev.resistance.maps.mq

import org.slf4j.LoggerFactory
import org.springframework.amqp.rabbit.annotation.RabbitListener
import org.springframework.stereotype.Component

@Component
class HeavyTaskProcessor {
    private val log = LoggerFactory.getLogger(javaClass)

    @RabbitListener(queues = [RabbitConfig.QUEUE])
    fun process(message: String) {
        log.info("Processing heavy task: {}", message)
        // Simulate heavy work
        Thread.sleep(500)
        log.info("Done heavy task: {}", message)
    }
}
