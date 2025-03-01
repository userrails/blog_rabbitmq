# app/services/rabbitmq/consumers/blog_consumer.rb
module RabbitMQ
  module Consumers
    class BlogConsumer
      QUEUE_NAME = 'blog_events'
      EXCHANGE_NAME = 'blogs.topic'
      
      def self.start
        new.start
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
            process_message(delivery_info, properties, payload)
            @channel.ack(delivery_info.delivery_tag)
          rescue => e
            # Reject and don't requeue if we can't process it
            @channel.reject(delivery_info.delivery_tag, false)
            Rails.logger.error "Error processing message: #{e.message}"
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
        Rails.logger.info "Blog created: #{data['title']}"
        # Here you would typically do something like:
        # - Update a search index
        # - Generate notifications
        # - Update counters
      end
      
      def handle_blog_updated(data)
        Rails.logger.info "Blog updated: #{data['title']}"
        # Process the updated blog
      end
      
      def handle_blog_deleted(data)
        Rails.logger.info "Blog deleted: ID #{data['id']}"
        # Handle the blog deletion
      end
    end
  end
end
