require 'jack'
require 'thread'
require 'rake'

module Jack
  class Task < Rake::Task
    def execute(args)
      Thread.current[:task] = self
      super
    ensure
      Thread.current[:task] = nil
    end
  end
end

include Jack::Tasks