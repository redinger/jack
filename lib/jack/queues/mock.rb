module Jack
  module Queues
    module Mock
      def connection
        @connection ||= []
      end
      
      def messages
        @messages ||= (connection.shift || [])
      end
      
      def delete(message)
        messages.delete message
      end
      
      def create(name_or_data, data = nil)
        if data.nil?
          data         = name_or_data
          name_or_data = @queue_name
        end
        created << [name_or_data, data]
      end
      
      def created
        @created ||= []
      end
    end
  end
end