require 'base64'
require 'net/imap'
require 'tmail'

module Jack
  module Queues
    module Imap
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
            message_ids = search(@options[:search] ? @options[:search].split(' ') : %w(ALL))
            @messages = connection.fetch(message_ids.size > @options[:limit] ? message_ids[0..@options[:limit]-1] : message_ids, 'RFC822')
            @messages.collect! { |m| Message.new(m.seqno, m.attr['RFC822']) }
          end
          logger.info("[Imap] Found #{@messages.size} message(s)")
        end
        @messages
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
        attr_reader :bodies
        attr_reader :html_bodies
        attr_reader :attachments
        attr_reader :msg
        attr_reader :raw
        attr_reader :number
      
        def initialize(number, raw = nil)
          @from = @to = @cc = @bcc = nil
          @number  = number
          @raw     = raw
          return if @raw.nil?
          @msg         = TMail::Mail.parse(raw)
          @bodies      = []
          @html_bodies = []
          @attachments = []
          process_parts
        end
        
        def subject
          @msg['subject']
        end
        
        %w(from to cc bcc).each do |addy|
          define_method addy do
            value = instance_variable_get("@#{addy}")
            if value.nil?
              value = @msg[addy].addrs.collect { |a| a.local }
              instance_variable_set("@#{addy}", value)
            end
            value
          end
        end
      
        def body
          @body ||= 
            if @bodies.any?
              @bodies.first.body
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
            case part['content-type'].content_type
              when 'text/plain' then @bodies << part
              when 'text/html'  then @html_bodies << part
              else @attachments << part
            end
          end
      end
    end
  end
end