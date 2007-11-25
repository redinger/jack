require 'base64'
require 'net/imap'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'tmail', 'lib')
require 'tmail'

module Jack
  module Queues
    module Imap
      class Error < StandardError
        def initialize(email, message)
          @email = email
          super(message)
        end
      end

      # :host, :port, :use_ssl, :user, :password
      def connection
        if @connection.nil? || @connection.disconnected?
          options = connection_args.first
          @connection = Net::IMAP.new(options[:host], options[:port], options[:use_ssl])
          @connection.login options[:user], options[:password]
        end
        @connection
      end

      def messages
        if @messages.nil?
          @options[:limit] ||= 15
          in_mailbox @queue_name do
            message_ids = search(*@options[:search].to_s.split(' '))
            if message_ids.size > 0
              @messages = connection.fetch(message_ids.size > @options[:limit] ? message_ids[0..@options[:limit]-1] : message_ids, 'RFC822')
              @messages.collect! { |m| Message.new(m.seqno, m.attr['RFC822']) }
            else
              @messages = []
            end
          end
          logger.info("[Imap] Found #{@messages.size} message(s)")
        end
        @messages
      end
      
      def delete_mailbox(mailbox)
        logger.info("[Imap] Deleting mailbox: #{mailbox.inspect}")
        connection.delete(mailbox)
      end
      
      def delete(message)
        logger.info("[Imap] Deleting message...")
        in_mailbox @queue_name do
          delete_messages([message])
        end
      end
      
      def search(*args, &block)
        args = %w(ALL) if args.empty?
        connection.search *args
      end
      
      def list_mailboxes(refname = '', mailbox = '*')
        mailboxes = []
        connection.list(refname, mailbox).each do |m|
          mailboxes << m.name if !block_given? || yield(m)
        end
        mailboxes
      end
      
      def in_mailbox(name)
        connection.select name
        retval = yield
        connection.close
        retval
      end
      
      def move_messages(messages, dest)
        return if messages.empty?
        messages = messages.collect { |m| m.number } if messages.first.respond_to?(:number)
        connection.copy messages, dest
        delete_messages messages
      end
      
      def delete_messages(messages)
        return if messages.empty?
        messages = messages.collect { |m| m.number } if messages.first.respond_to?(:number)
        connection.store messages, "+FLAGS", [:Deleted]
      end

      class Message
        class << self
          attr_accessor :parsing_delimiter
        end
        attr_reader :bodies
        attr_reader :html_bodies
        attr_reader :attachments
        attr_reader :msg
        attr_reader :raw
        attr_reader :number
        attr_reader :subject
        attr_reader :from
        attr_reader :to
        attr_reader :cc
        attr_reader :bcc
      
        def initialize(number, raw = nil)
          @error = @from = @to = @cc = @bcc = nil
          @number  = number
          @raw     = raw
          return if @raw.nil?
          @msg         = TMail::Mail.parse(raw)
          @subject     = @msg['subject'].to_s.strip
          @from        = process_message_addresses :from
          @to          = process_message_addresses :to
          @cc          = process_message_addresses :cc
          @bcc         = process_message_addresses :bcc
          @bodies      = []
          @html_bodies = []
          @attachments = []
          process_parts
        rescue Error
          error!
        end

        def error!
          @error = true
        end

        def error?
          @error
        end
        
        def subject
          @subject ||= @msg['subject']
        end
      
        def body
          @body ||= 
            if @bodies.any?
              @bodies.first.body
            else
              ''
            end
        end

        self.parsing_delimiter = ("=" * 50).freeze
        # returns lines separated by = * 50
        def split_by_delimiter(delimiter = self.class.parsing_delimiter)
          return '' if body.nil? || body.empty?
          lines = body.split("\n")
          delim_line = last_line = found_empty = nil
      
          lines.each_with_index do |line, i|
            next if delim_line
            delim_line = i if line.include?(delimiter)
          end
      
          while !last_line && delim_line.to_i > 0
            delim_line = delim_line - 1
            if found_empty
              last_line = delim_line if lines[delim_line].strip.size > 0
            else
              found_empty = true if lines[delim_line].strip.size.zero?
            end
          end
      
          if last_line
            lines[0..delim_line] * "\n"
          elsif delim_line.nil?
            body.strip
          else
            ''
          end
        end

      protected
        def process_parts(part = nil)
          part ||= @msg
          if part.parts.each do |p|
            process_parts p
          end.empty?
            process_body part
          end
        end
        
        def process_body(part)
          if part['content-type'].nil?
            raise Error.new(self, "Malformed Headers")
          end

          case part['content-type'].content_type
            when 'text/plain' then @bodies << part
            when 'text/html'  then @html_bodies << part
            else @attachments << part
          end
        end
        
        def process_message_addresses(key)
          field = @msg[key.to_s]
          return if field.nil?
          field.addrs.inject [] do |addresses, address|
            if address.respond_to?(:local)
              addresses << address.local.strip
            else
              addresses
            end
          end
        end
      end
    end
  end
end
