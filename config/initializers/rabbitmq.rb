# config/initializers/rabbitmq.rb
require 'bunny'
require Rails.root.join('app', 'services', 'rabbitmq', 'connection_manager')

# Establish connection on Rails startup if not in test environment
unless Rails.env.test?
  begin
    # Initialize connection
    RabbitMQ::ConnectionManager.connection
    
    # Declare default exchange
    channel = RabbitMQ::ConnectionManager.channel
    channel.topic('blogs.topic', durable: true)
    
    Rails.logger.info "RabbitMQ connection established"
  rescue => e
    Rails.logger.error "Failed to connect to RabbitMQ: #{e.message}"
  end
end

# Close connection on Rails shutdown
at_exit do
  RabbitMQ::ConnectionManager.close_connection
end
