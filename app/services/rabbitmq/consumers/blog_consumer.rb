# app/services/rabbitmq/consumers/blog_consumer.rb
module RabbitMQ
  module Consumers
    class BlogConsumer
      QUEUE_NAME = 'blog_events'
      EXCHANGE_NAME = 'blogs.topic'
      
      def self.start
        puts "Starting RabbitMQ consumer..."
        consumer = new
        consumer.start
        # Add this loop to keep the process running
        puts "Consumer started, waiting for messages..."
        loop do
          sleep 1
        end
      end
      
      def initialize
        @channel = RabbitMQ::ConnectionManager.channel
        @exchange = @channel.topic(EXCHANGE_NAME, durable: true)
        
        # Create queue
        @queue = @channel.queue(QUEUE_NAME, durable: true)
        
        # Bind queue to exchange with routing patterns
        @queue.bind(@exchange, routing_key: 'blog.created')
        @queue.bind(@exchange, routing_key: 'blog.updated')
        @queue.bind(@exchange, routing_key: 'blog.deleted')
      end
      
      def start
        @queue.subscribe(manual_ack: true) do |delivery_info, properties, payload|
          begin
            puts "Received message with routing key: #{delivery_info.routing_key}"
            process_message(delivery_info, properties, payload)
            @channel.ack(delivery_info.delivery_tag)
          rescue => e
            # Reject and don't requeue if we can't process it
            @channel.reject(delivery_info.delivery_tag, false)
            Rails.logger.error "Error processing message: #{e.message}"
            puts "Error processing message: #{e.message}"
          end
        end
      end
      
      private
      
      def process_message(delivery_info, properties, payload)
        data = JSON.parse(payload)
        routing_key = delivery_info.routing_key
        
        case routing_key
        when 'blog.created'
          handle_blog_created(data)
        when 'blog.updated'
          handle_blog_updated(data)
        when 'blog.deleted'
          handle_blog_deleted(data)
        end
      end
      
      def handle_blog_created(data)
        message = "Blog created: #{data['title']}"
        Rails.logger.info message
        puts message
      end
      
      def handle_blog_updated(data)
        message = "Blog updated: #{data['title']}"
        Rails.logger.info message
        puts message
      end
      
      def handle_blog_deleted(data)
        message = "Blog deleted: ID #{data['id']}"
        Rails.logger.info message
        puts message
      end
    end
  end
end