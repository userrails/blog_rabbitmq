# config/initializers/rabbitmq_autoload.rb
require Rails.root.join('app/services/rabbitmq/connection_manager')
require Rails.root.join('app/services/rabbitmq/publishers/blog_publisher')
require Rails.root.join('app/services/rabbitmq/consumers/blog_consumer')
