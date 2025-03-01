# app/services/rabbitmq/publishers/blog_publisher.rb
module RabbitMQ
  module Publishers
    class BlogPublisher
      EXCHANGE_NAME = 'blogs.topic'
      
      class << self
        def publish_created(blog)
          publish(blog, 'blog.created')
        end
        
        def publish_updated(blog)
          publish(blog, 'blog.updated')
        end
        
        def publish_deleted(blog_id)
          publish({ id: blog_id }, 'blog.deleted')
        end
        
        private
        
        def publish(data, routing_key)
          channel = RabbitMQ::ConnectionManager.channel
          exchange = channel.topic(EXCHANGE_NAME, durable: true)
          
          message = data.is_a?(Hash) ? data : data.as_json
          exchange.publish(
            message.to_json,
            routing_key: routing_key,
            persistent: true,
            content_type: 'application/json'
          )
          
          Rails.logger.info "Published message to #{EXCHANGE_NAME} with routing key #{routing_key}: #{message.to_json}"
        end
      end
    end
  end
end
