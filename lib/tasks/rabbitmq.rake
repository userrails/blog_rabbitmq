# lib/tasks/rabbitmq.rake
namespace :rabbitmq do
  desc "Start the RabbitMQ consumer"
  task consumer: :environment do
    require Rails.root.join('app/services/rabbitmq/connection_manager')
    require Rails.root.join('app/services/rabbitmq/consumers/blog_consumer')
    
    begin
      puts "Starting RabbitMQ consumer via rake task..."
      RabbitMQ::Consumers::BlogConsumer.start
    rescue => e
      puts "Error in RabbitMQ consumer: #{e.message}"
      puts e.backtrace
    end
  end
end