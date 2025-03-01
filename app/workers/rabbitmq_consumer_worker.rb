# app/workers/rabbitmq_consumer_worker.rb
class RabbitmqConsumerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform
    RabbitMQ::Consumers::BlogConsumer.start
  end
end