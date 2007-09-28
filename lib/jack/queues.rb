module Jack
  module Queues
    def process_queue(queue_name, options = {}, &block)
      Queues::Task.queue_task(queue_name, options, &block)
    end
  
    def queue
      Thread.current[:task]
    end
    
    class Task < Jack::Task
      attr_accessor :queue_name
      attr_accessor :connection_args
      attr_accessor :options
  
      def kept
        @kept ||= []
      end
  
      def keep(*messages)
        messages.flatten!
        messages.uniq!
        kept.push *messages
      end
    
      def execute
        task = lambda do
          if messages.empty?
            false
          else
            super
            (messages - kept).each do |msg|
              delete msg
            end
            kept.empty?
          end
        end
        while task.call
          @messages = nil
        end
      end
  
      class << self
        attr_accessor :default_connection_args
      end
  
      def self.queue_task(name, options = {}, &block)
        task = define_task(name, &block)
        task.queue_name      = options.delete(:queue_name) || name
        task.options         = options
        task.connection_args = options.delete(:connect) || default_connection_args
        task
      end
    end
  end
end