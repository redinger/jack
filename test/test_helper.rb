$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'test/unit'
require 'jack'
require 'test/spec'
require 'mocha'

JACK = Object.new
JACK.extend Jack::Tasks
class << JACK
  def include(*args)
    extend(*args)
  end
  
  def logger_stream
    @logger_stream ||= StringIO.new
  end
  
  def execute_command(cmd)
    cmd
  end
end

JACK.setup_queue :mock
JACK.setup_s3 :bucket => 'stuff', :working => 'foo/bar', :access_key_id => 'abc', :secret_access_key => 'def'
JACK.setup_logger JACK.logger_stream