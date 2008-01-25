require 'logger'
require 'jack/tasks/ffmpeg'
require 'jack/tasks/locking'

module Jack
  module Tasks
    def setup_queue(queue_type, *args)
      require "jack/queues"
      require "jack/queues/#{queue_type}"
      include Jack::Queues
      mod = Jack::Queues.const_get(queue_type.to_s.capitalize)
      Jack::Queues::Task.send :include, mod
      Jack::Queues::Task.default_connection_args = args
    end
    
    def setup_s3(options)
      require 'jack/tasks/s3'
      @default_s3_bucket = options.delete(:bucket)
      @s3_working_path   = options.delete(:working).to_s
      AWS::S3::Base.establish_connection!(options) if options.any?
      include Jack::Tasks::S3
    end
    
    def setup_logger(*args)
      @logger = Logger.new(*args)
    end
    
    def logger
      @logger ||= Logger.new(STDERR)
    end
    
    def jack_task(*args, &block)
      require 'jack/rake'
      Jack::Task.define_task(*args, &block)
    end

    include Jack::Tasks::Ffmpeg
    include Jack::Tasks::Locking
  end
end