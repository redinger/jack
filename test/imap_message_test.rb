require File.join(File.dirname(__FILE__), 'test_helper')
require 'jack/queues/imap'

module ImapMessageSpecHelper
  def self.imap_fixture_path
    @imap_fixture_path ||= File.join(File.dirname(__FILE__), 'fixtures')
  end
  
  def messages(fixture_name)
    raw = File.read File.join(ImapMessageSpecHelper.imap_fixture_path, "#{fixture_name}.txt")
    Jack::Queues::Imap::Message.new(1, raw)
  end
end

describe "IMAP Message (multi part, plain/text and html)" do
  include ImapMessageSpecHelper
  
  before do
    @message = messages(:exchange_multi_part_html)
  end
  
  it "should parse from address" do
    @message.from.should == %w(bob@example.com)
  end
  
  it "should parse to address" do
    @message.to.should == %w(ticket+sample@lighthouseapp.com)
  end
  
  it "should parse subject" do
    @message.subject.should == 'problem with audio capture and usb pre-amps'
  end
  
  it "should parse parts" do
    @message.msg.parts.size.should == 2
  end
  
  it "should parse body" do
    @message.bodies.size.should == 1
  end
  
  it "should parse html bodies" do
    @message.html_bodies.size.should == 1
  end
  
  it "should parse attachments" do
    @message.attachments.size.should == 1
  end
end

describe "IMAP Message (single part, plain/text)" do
  include ImapMessageSpecHelper

  before do
    @message = messages(:single_part_plain)
  end
  
  it "should parse from address" do
    @message.from.should == %w(rick@example.com)
  end
  
  it "should parse to address" do
    @message.to.should == %w(ticket@example.com)
  end
  
  it "should parse cc address" do
    @message.cc.should == %w(bob@example.com)
  end
  
  it "should parse bcc address" do
    @message.bcc.should == %w(fred@example.com quentin@example.com)
  end
  
  it "should parse subject" do
    @message.subject.should == 'test'
  end
  
  it "should parse single part" do
    @message.bodies.size.should == 1
  end

  it "should parse html bodies" do
    @message.html_bodies.size.should == 0
  end
  
  it "should parse attachments" do
    @message.attachments.size.should == 0
  end

  it "should parse body content type" do
    @message.bodies.first.content_type.should == 'text/plain'
  end
  
  it "should parse body" do
    @message.body.should =~ /Testing email stuff/
  end
  
  it "should have no parts" do
    @message.msg.parts.should.be.empty
  end
  
  it "should have no attachments" do
    @message.attachments.should.be.empty
  end
  
  it "should have no html bodies" do
    @message.html_bodies.should.be.empty
  end
end

describe "IMAP Message" do
  it "separates update text from reply text" do
    msg = Jack::Queues::Imap::Message.new 1
    delim = "=" * 50
    {
      "foo bar\n\n#{delim}\nfoo" => "foo bar", 
      "foo\n  bar\nbaz\n\n\n> #{delim}" => "foo\n  bar\nbaz",
      "foo\n\nbar\nbaz\n#{delim}" =>  "foo",
      "foo\n  bar\nbaz2\n\n\n\n" => "foo\n  bar\nbaz2",
      ">> #{delim}\n foo bar" => ""
    }.each do |before, after|
      msg.instance_variable_set :@body, before
      msg.split_by_delimiter.should == after
    end
  end
end