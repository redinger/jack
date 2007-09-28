require 'appcast/client'
module Jack
  module Queues
    module Appcast
      def connection
        @connection ||= ::Appcast::Client.new(*connection_args)
      end
      
      def messages
        if @messages.nil?
          @messages = connection.list(@queue_name, @options)
          logger.info("[Appcast] Found #{@messages.size} message(s)")
        end
        @messages
      end
      
      def delete(message)
        logger.info("[Appcast] Deleting message for #{message.name}")
        message.destroy
      end
      
      def create(name_or_data, data = nil)
        if data.nil?
          data         = name_or_data
          name_or_data = @queue_name
        end
        logger.info("[Appcast] Created message for #{name_or_data}")
        connection.create(name_or_data, data)
      end
    end
  end
end