require File.join(File.dirname(__FILE__), 'test_helper')

context "Jack Queues" do
  specify "should provide access to queue object" do
    @task = JACK.process_queue :queue_object do
      JACK.poke
      JACK.queue.should == @task
    end
    JACK.expects(:poke)
    @task.connection << [:msg]
    @task.execute
  end
  
  specify "should create message with current queue name" do
    @task = JACK.process_queue :create do
      JACK.poke
      JACK.queue.create :foo
    end
    JACK.expects(:poke)
    @task.connection << [:msg]
    @task.execute
    @task.created.should == [[:create, :foo]]
  end
  
  specify "should create message with custom queue name" do
    @task = JACK.process_queue :create_custom do
      JACK.poke
      JACK.queue.create :foo, :bar
    end
    JACK.expects(:poke)
    @task.connection << [:msg]
    @task.execute
    @task.created.should == [[:foo, :bar]]
  end
  
  specify "should set queue name to task name" do
    @task = JACK.process_queue(:queue_name) {}
    @task.queue_name.should == :queue_name
  end
  
  specify "should set options and custom queue name" do
    @task = JACK.process_queue(:queue_options, :queue_name => :foo, :example => :option) {}
    @task.queue_name.should == :foo
    @task.options.should == {:example => :option}
  end
  
  specify "should execute queue task" do
    @task = JACK.process_queue :queue_task do
      JACK.poke
      JACK.queue.messages.should == [:msg, :keep]
      JACK.queue.keep :keep
    end
    JACK.expects(:poke)
    @task.connection << [:msg, :keep] << [:msg2] # store messages
    @task.execute
  end
  
  specify "should loop queue task" do
    @task = JACK.process_queue :queue_loop do
      if JACK.poke == 1
        JACK.queue.messages.should == [:msg, :msg2]
      else
        JACK.queue.messages.should == [:msg3]
      end
    end
    JACK.expects(:poke).times(2).returns(1,2)
    @task.connection << [:msg, :msg2] << [:msg3] # store messages
    @task.execute
    @task.messages.should.be.empty
  end
end