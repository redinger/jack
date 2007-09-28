module Jack
  module Tasks
    module Locking
      def lock(*args)
        require 'lockfile' unless Object.const_defined?(:Lockfile)
        options = args.last.is_a?(Hash) ? args.pop : {:retries => 0}
        lock_filename = args.shift || 'jack.lock'
        if block_given?
          lockfile = ::Lockfile.new(lock_filename, options)
          begin
            lockfile.lock
            yield
          ensure
            lockfile.unlock if lockfile.locked?
          end
        end
      end
    end
  end
end