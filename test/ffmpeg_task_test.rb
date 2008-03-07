require File.join(File.dirname(__FILE__), 'test_helper')

context "Jack::Tasks::Ffmpeg" do
  @@ffmpeg_answers = {
    :dimensions => %w(480x360 640x480 960x528 480x360 960x528),
    :duration   => [34, 407, 2616, 15, 2616],
    :fps        => [30.0, 29.97, 23.98, 25, 23.98],
    :stream     => {:video => %w(0:6 0:0 0:0 0:6 0:0), :audio => %w(0:7 0:1 0:1 0:7)},
    :frequency  => [44100, 44100, 48000, 44100, nil]
  }
  @@ffmpeg_examples = []
  @@ffmpeg_examples << <<-END
FFmpeg version SVN-r9607, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-static --disable-vhook
  libavutil version: 49.4.1
  libavcodec version: 51.40.4
  libavformat version: 51.12.1
  built on Jul 12 2007 10:58:21, gcc: 4.0.1 (Apple Computer, Inc. build 5367)

Seems stream 6 codec frame rate differs from container frame rate: 1000.00 (1000/1) -> 30.00 (30/1)
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '/Users/bob/Desktop/example1.mov':
  Duration: 00:00:34.1, start: 0.000000, bitrate: 275 kb/s
  Stream #0.0(eng): Data: 0x0000
  Stream #0.1(eng): Data: 0x0000
  Stream #0.2(eng): Video: mjpeg, yuvj444p, 480x360,  0.33 fps(r)
  Stream #0.3(eng): Data: text / 0x74786574
  Stream #0.4(eng): Video: qtrle, rgb32, 32x2,  0.33 fps(r)
  Stream #0.5(eng): Data: 0x0000
  Stream #0.6(eng): Video: mpeg4, yuv420p, 480x360, 30.00 fps(r)
  Stream #0.7(eng): Audio: mp4a / 0x6134706D, 44100 Hz, stereo
Must supply at least one output file
END
  @@ffmpeg_examples << <<-END
FFmpeg version SVN-r9607, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-static --disable-vhook
  libavutil version: 49.4.1
  libavcodec version: 51.40.4
  libavformat version: 51.12.1
  built on Jul 12 2007 10:58:21, gcc: 4.0.1 (Apple Computer, Inc. build 5367)

Seems stream 0 codec frame rate differs from container frame rate: 30000.00 (30000/1) -> 29.97 (30000/1001)
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '/Users/bob/Desktop/example2.mov':
  Duration: 00:06:46.9, start: 0.000000, bitrate: 3387 kb/s
  Stream #0.0(eng): Video: mpeg4, yuv420p, 640x480, 29.97 fps(r)
  Stream #0.1(eng): Audio: mp4a / 0x6134706D, 44100 Hz, stereo
Must supply at least one output file
END
  @@ffmpeg_examples << <<-END
FFmpeg version SVN-r9607, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-static --disable-vhook
  libavutil version: 49.4.1
  libavcodec version: 51.40.4
  libavformat version: 51.12.1
  built on Jul 12 2007 10:58:21, gcc: 4.0.1 (Apple Computer, Inc. build 5367)

Seems stream 0 codec frame rate differs from container frame rate: 23.98 (65535/2733) -> 23.98 (24000/1001)
Input #0, avi, from '/Users/bob/Desktop/example3.avi':
  Duration: 00:43:35.7, start: 0.000000, bitrate: 2245 kb/s
  Stream #0.0: Video: mpeg4, yuv420p, 960x528, 23.98 fps(r)
  Stream #0.1: Audio: 0x2000, 48000 Hz, 5:1, 448 kb/s
Must supply at least one output file
END

  @@ffmpeg_examples << <<-END
Fmpeg version SVN-r11532, Copyright (c) 2000-2008 Fabrice Bellard, et al.
  configuration: --prefix=/opt/local --prefix=/opt/local --disable-vhook --mandir=/opt/local/share/man --enable-shared --enable-pthreads --disable-mmx
  libavutil version: 49.6.0
  libavcodec version: 51.49.0
  libavformat version: 52.4.0
  libavdevice version: 52.0.0
  built on Jan 22 2008 19:08:05, gcc: 4.0.1 (Apple Inc. build 5465)

Seems stream 6 codec frame rate differs from container frame rate: 1000.00 (1000/1) -> 25.00 (25/1)
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '/Users/bob/Desktop/example3.avi':
  Duration: 00:00:15.0, start: 0.000000, bitrate: 597 kb/s
    Stream #0.0(eng): Data: 0x0000
    Stream #0.1(eng): Data: 0x0000
    Stream #0.2(eng): Video: mjpeg, yuvj444p, 480x360 [PAR 100:100 DAR 4:3],  0.33 tb(r)
    Stream #0.3(eng): Data: text / 0x74786574
    Stream #0.4(eng): Video: qtrle, rgb32, 32x2 [PAR 0:1 DAR 0:1],  0.33 tb(r)
    Stream #0.5(eng): Data: 0x0000
    Stream #0.6(eng): Video: mpeg4, yuv420p, 480x360 [PAR 1:1 DAR 4:3], 25.00 tb(r)
    Stream #0.7(eng): Audio: mp4a / 0x6134706D, 44100 Hz, stereo
END
  @@ffmpeg_examples << <<-END
FFmpeg version SVN-r9607, Copyright (c) 2000-2007 Fabrice Bellard, et al.
  configuration: --enable-libmp3lame --enable-static --disable-vhook
  libavutil version: 49.4.1
  libavcodec version: 51.40.4
  libavformat version: 51.12.1
  built on Jul 12 2007 10:58:21, gcc: 4.0.1 (Apple Computer, Inc. build 5367)

Seems stream 0 codec frame rate differs from container frame rate: 23.98 (65535/2733) -> 23.98 (24000/1001)
Input #0, avi, from '/Users/bob/Desktop/example3.avi':
  Duration: 00:43:35.7, start: 0.000000, bitrate: 2245 kb/s
  Stream #0.0: Video: mpeg4, yuv420p, 960x528,  23.98  fps(r)
Must supply at least one output file
END

  specify "should parse ffmpeg info output into hash" do
    JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples.first.split("\n"))
    JACK.movie_info_for('/filename').class.should == Hash
  end
  
  specify "should return guessed screenshot filename after grabbing" do
    JACK.expects(:ffmpeg).with('foo.mov', :vframes => 1, :format => :image2, :disable_audio => true, :size => '100x100', :file => 'foo.mov.jpg')
    JACK.grab_screenshot_from('foo.mov', '100x100').should == 'foo.mov.jpg'
  end
  
  specify "should fix odd size dimensions when grabbing screenshot" do
    JACK.expects(:ffmpeg).with('foo.mov', :vframes => 1, :format => :image2, :disable_audio => true, :size => '100x98', :file => 'foo.mov.jpg')
    JACK.grab_screenshot_from('foo.mov', '101x99').should == 'foo.mov.jpg'
  end
  
  specify "should fix odd size dimensions when converting to flv" do
    JACK.expects(:ffmpeg).with('foo.mov', :rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => '100x98', :file => 'foo.mov.flv')
    JACK.convert_to_flv('foo.mov', '101x99').should == 'foo.mov.flv'
  end
  
  specify "should return guessed screenshot filename after grabbing with options" do
    JACK.expects(:ffmpeg).with('foo.mov', :vframes => 1, :format => :image2, :disable_audio => true, :size => '100x100', :file => 'foo.mov.jpg', :foo => :bar)
    JACK.grab_screenshot_from('foo.mov', '100x100', :foo => :bar).should == 'foo.mov.jpg'
  end
  
  specify "should add multiple params for array options" do
    JACK.expects(:execute_command).with("ffmpeg -i #{File.expand_path('foo.mov')} -map 0:1 -map 0:2")
    JACK.ffmpeg('foo.mov', :map => %w(0:1 0:2))
  end

  specify "should return given screenshot filename after grabbing" do
    JACK.expects(:ffmpeg).with('foo.mov', :vframes => 1, :format => :image2, :disable_audio => true, :size => '100x100', :file => 'foo.jpg')
    JACK.grab_screenshot_from('foo.mov', '100x100', 'foo.jpg').should == 'foo.jpg'
  end
  
  specify "should return given screenshot filename after grabbing with options" do
    JACK.expects(:ffmpeg).with('foo.mov', :vframes => 1, :format => :image2, :disable_audio => true, :size => '100x100', :file => 'foo.jpg', :foo => :bar)
    JACK.grab_screenshot_from('foo.mov', '100x100', 'foo.jpg', :foo => :bar).should == 'foo.jpg'
  end

  specify "should return guessed flv filename after generating" do
    JACK.expects(:ffmpeg).with('foo.mov', :rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => '100x100', :file => 'foo.mov.flv')
    JACK.convert_to_flv('foo.mov', '100x100').should == 'foo.mov.flv'
  end
  
  specify "should return guessed flv filename after generating with options" do
    JACK.expects(:ffmpeg).with('foo.mov', :rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => '100x100', :file => 'foo.mov.flv', :foo => :bar)
    JACK.convert_to_flv('foo.mov', '100x100', :foo => :bar).should == 'foo.mov.flv'
  end

  specify "should return given flv filename after generating" do
    JACK.expects(:ffmpeg).with('foo.mov', :rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => '100x100', :file => 'foo.flv')
    JACK.convert_to_flv('foo.mov', '100x100', 'foo.flv').should == 'foo.flv'
  end
  
  specify "should return given flv filename after generating with options" do
    JACK.expects(:ffmpeg).with('foo.mov', :rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => '100x100', :file => 'foo.flv', :foo => :bar)
    JACK.convert_to_flv('foo.mov', '100x100', 'foo.flv', :foo => :bar).should == 'foo.flv'
  end

  specify "should grab video dimensions" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:dimensions].should == @@ffmpeg_answers[:dimensions][i]
    end
  end
  
  specify "should grab video duration" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:duration].should == @@ffmpeg_answers[:duration][i]
    end
  end
  
  specify "should grab video fps" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:fps].should == @@ffmpeg_answers[:fps][i]
    end
  end
  
  specify "should grab video stream" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:video_stream].should == @@ffmpeg_answers[:stream][:video][i]
    end
  end
  
  specify "should grab audio stream" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:audio_stream].should == @@ffmpeg_answers[:stream][:audio][i]
    end
  end
  
  specify "should grab audio frequency" do
    @@ffmpeg_examples.each_with_index do |ex, i|
      JACK.expects(:ffmpeg).with("/filename").returns(@@ffmpeg_examples[i].split("\n"))
      JACK.movie_info_for('/filename')[:frequency].should == @@ffmpeg_answers[:frequency][i]
    end
  end
end