require File.join(File.dirname(__FILE__), 'test_helper')

context "Jack Tasks" do
  specify "should store instance in current thread while executing" do
    @task = Jack::Task.define_task :test_thread do
      Thread.current[:task].should == @task
    end

    Thread.current[:task].should.be.nil
    @task.execute
    Thread.current[:task].should.be.nil
  end
  
  specify "should setup s3 bucket name" do
    JACK.default_s3_bucket.should == 'stuff'
  end
  
  specify "should setup s3 working path" do
    JACK.s3_working_path.should == 'foo/bar'
  end
  
  specify "should set s3 connection options" do
    AWS::S3::Base.connection.options[:access_key_id].should     == 'abc'
    AWS::S3::Base.connection.options[:secret_access_key].should == 'def'
  end
  
  specify "should store with default bucket and options" do
    @stream = stub
    JACK.expects(:open).with('filename').returns(@stream)
    AWS::S3::S3Object.expects(:store).with('foo', @stream, 'stuff', {:expires => 300})
    JACK.store_in_s3 'foo', 'filename', :expires => 300
  end
  
  specify "should store with custom bucket and options" do
    @stream = stub
    JACK.expects(:open).with('filename').returns(@stream)
    AWS::S3::S3Object.expects(:store).with('foo', @stream, 'things', {:expires => 300})
    JACK.store_in_s3 'foo', 'filename', 'things', :expires => 300
  end

  specify "should download from s3 from default bucket" do
    @stream = StringIO.new
    Dir.expects(:chdir).with(JACK.s3_working_path).yields
    JACK.expects(:open).with('foo', 'w').yields(@stream)
    AWS::S3::S3Object.expects(:stream).with('foo', 'stuff').yields("content")
    JACK.download_from_s3 'foo'
    @stream.rewind
    @stream.read.should == 'content'
  end

  specify "should download from s3 from custom bucket" do
    @stream = StringIO.new
    Dir.expects(:chdir).with(JACK.s3_working_path).yields
    JACK.expects(:open).with('foo', 'w').yields(@stream)
    AWS::S3::S3Object.expects(:stream).with('foo', 'things').yields("content")
    JACK.download_from_s3 'foo', 'things'
    @stream.rewind
    @stream.read.should == 'content'
  end

  specify "should delete with default s3 bucket" do
    AWS::S3::S3Object.expects(:delete).with('foo', 'stuff')
    JACK.delete_from_s3 'foo'
  end
  
  specify "should delete with custom s3 bucket" do
    AWS::S3::S3Object.expects(:delete).with('foo', 'things')
    JACK.delete_from_s3 'foo', 'things'
  end
  
  specify "should create ffmpeg command" do
    File.expects(:expand_path).with('foo').returns('foo_path')
    File.expects(:expand_path).with('bar').returns('bar_path')
    JACK.ffmpeg('foo', :file => 'bar').should == "ffmpeg -i foo_path bar_path"
  end

  {
    [:duration, 3]        => [:t],
    [:rate, 3]            => [],
    [:seek, 3]            => [:ss],
    [:verbose, true]      => [:v, :verbose],
    [:size, 3]            => [],
    [:overwrite, nil]     => [:y],
    [:format, :test]      => [:f],
    [:frequency, :test]   => [:ar],
    [:abitrate, :test]    => [:ab],
    [:disable_video, nil] => [:vn],
    [:disable_audio, nil] => [:an],
    [:whatever, :test]    => [:whatever]
  }.each do |args, expected|
    specify "should recognize ffmpeg argument -#{args[0]}" do
      File.expects(:expand_path).with('foo').returns('foo_path')
      File.expects(:expand_path).with('bar').returns('bar_path')
      switch = expected[0] || args[0].to_s[0..0]
      value  = args[1] ? " #{expected[1] || args[1]}" : nil
      JACK.ffmpeg('foo', args[0] => args[1], :file => 'bar').should == "ffmpeg -i foo_path -#{switch}#{value} bar_path"
    end
  end
end

