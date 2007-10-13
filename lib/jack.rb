require 'rubygems'
require 'rake'
require 'thread'
require 'jack/tasks'
$LOAD_PATH << File.join(File.dirname(__FILE__), 'vendor')

module Jack
  VERSION = '1.0.0'

  class Task < Rake::Task
    def execute
      Thread.current[:task] = self
      super
    ensure
      Thread.current[:task] = nil
    end
  end
end

include Jack::Tasks