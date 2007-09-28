require 'open4'

module Jack
  module Tasks
    module Ffmpeg
      def ffmpeg(input, options = {})
        cmd = ['ffmpeg']
        input = { :file => input } unless input.is_a?(Hash)
        ffmpeg_options :input,  cmd, input
        ffmpeg_options :output, cmd, options
        execute_command cmd.join(" ")
      end
      
      def convert_to_flv(filename, size, output = nil, options = {})
        if output.is_a?(Hash)
          options = output
          output  = nil
        end
        default = {:rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => size, :file => (output || filename + ".flv")}
        ffmpeg filename, default.update(options)
        options[:file]
      end
      
      def grab_screenshot_from(filename, size, output = nil, options = {})
        if output.is_a?(Hash)
          options = output
          output  = nil
        end
        default = {:vframes => 1, :format => :image2, :disable_audio => true, :size => size, :file => (output || filename + ".jpg")}
        ffmpeg filename, default.update(options)
        options[:file]
      end
      
      protected
        def ffmpeg_options(param, cmd, options)
          file = options.delete(:file)
          options.inject(cmd) do |c, (key, value)|
            c << \
              case key
                when :duration  then "-t #{value}"
                when :rate      then "-r #{value}"
                when :bitrate   then "-b #{value}"
                when :seek      then "-ss #{value}"
                when :verbose   then "-v #{value == true ? :verbose : value}"
                when :size      then "-s #{value}"
                when :overwrite then "-y"
                when :format    then "-f #{value}"
                when :frequency then "-ar #{value}"
                when :abitrate  then "-ab #{value}"
                when :disable_video then "-vn"
                when :disable_audio then "-an"
                else "-#{key} #{value}"
              end
          end
          cmd << "#{param == :input ? '-i ' : ''}#{File.expand_path(file)}"
        end
        
        def execute_command(cmd)
          logger.info "[ffmpeg] Executing: #{cmd}"
          result = []
          Open4.popen4 cmd do |pid, stdin, stdout, stderr|
            result << stdout.read.to_s.strip
            result << stderr.read.to_s.strip
          end
          unless result.first.blank?
            logger.info "[ffmpeg] OUTPUT: #{result.first}"
          end
          unless result.last.blank?
            logger.debug "[ffmpeg] ERROR: #{result.last}"
          end
          result
        end
    end
  end
end