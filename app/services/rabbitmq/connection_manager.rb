# app/services/rabbitmq/connection_manager.rb
module RabbitMQ
  class ConnectionManager
    class << self
      def connection
        @connection ||= begin
          conn = Bunny.new(
            host: ENV.fetch('RABBITMQ_HOST', 'localhost'),
            port: ENV.fetch('RABBITMQ_PORT', '5672'),
            vhost: ENV.fetch('RABBITMQ_VHOST', '/'),
            user: ENV.fetch('RABBITMQ_USER', 'guest'),
            password: ENV.fetch('RABBITMQ_PASSWORD', 'guest')
          )
          conn.start
          conn
        end
      end

      def channel
        Thread.current[:rabbitmq_channel] ||= connection.create_channel
      end

      def close_connection
        return unless @connection

        @connection.close if @connection.open?
        @connection = nil
      end
    end
  end
end
