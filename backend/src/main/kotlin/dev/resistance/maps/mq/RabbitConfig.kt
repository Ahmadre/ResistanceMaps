package dev.resistance.maps.mq

import org.springframework.amqp.core.Binding
import org.springframework.amqp.core.BindingBuilder
import org.springframework.amqp.core.Queue
import org.springframework.amqp.core.TopicExchange
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class RabbitConfig {
    companion object {
        const val EXCHANGE = "heavy.exchange"
        const val QUEUE = "heavy.queue"
        const val ROUTING_KEY = "heavy.#"
    }

    @Bean
    fun heavyExchange() = TopicExchange(EXCHANGE)

    @Bean
    fun heavyQueue() = Queue(QUEUE, true)

    @Bean
    fun heavyBinding(queue: Queue, exchange: TopicExchange): Binding =
        BindingBuilder.bind(queue).to(exchange).with(ROUTING_KEY)
}
