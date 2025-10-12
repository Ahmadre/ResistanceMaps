package dev.resistance.maps.mq

import org.springframework.amqp.rabbit.core.RabbitTemplate
import org.springframework.stereotype.Service

@Service
class HeavyTaskPublisher(private val rabbitTemplate: RabbitTemplate) {
    fun publish(message: String) {
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, "heavy.task", message)
    }
}
