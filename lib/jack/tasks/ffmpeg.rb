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

      def movie_info_for(filename)
        output  = ffmpeg(filename).join("\n")
        returning({}) do |options|
          find_dimensions_from output, options
          find_duration_from   output, options
        end
      end
      
      def convert_to_flv(filename, size, output = nil, options = {})
        if output.is_a?(Hash)
          options = output
          output  = nil
        end
        options = {:rate => 25, :acodec => :mp3, :frequency => 22050, :overwrite => true, :size => size, :file => (output || filename + ".flv")}.update(options)
        ffmpeg filename, options
        options[:file]
      end
      
      def grab_screenshot_from(filename, size, output = nil, options = {})
        if output.is_a?(Hash)
          options = output
          output  = nil
        end
        options = {:vframes => 1, :format => :image2, :disable_audio => true, :size => size, :file => (output || filename + ".jpg")}.update(options)
        ffmpeg filename, options
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
          cmd << "#{param == :input ? '-i ' : ''}#{File.expand_path(file)}" if file
          cmd
        end

        def find_dimensions_from(output, options)
          # sometimes videos have multiple video streams
          # attempt to guess the valid one by using the one with the highest fps
          output.scan(/\#([\d\.]+)(\([^\)]+\))?: Video:[ \w,]* (\d+x\d+), ([\d\.]+) fps/).each do |result|
            stream, dimensions, fps = result[0].sub(/\./, ':'), result[2], result[3].to_f
            if options[:fps].to_f <= fps
              options.update :dimensions => dimensions, :fps => fps, :stream => stream
            end
          end
        end
      
        def find_duration_from(output, options)
          if output =~ /Duration: (\d{2}:\d{2}:\d{2}\.\d+)/
            options[:duration] = running_time_to_seconds($1)
          end
        end
      
        def running_time_to_seconds(time)
          pieces      = 
          multipliers = [1, 60, 3600]
          time.split(":").reverse.inject 0 do |seconds, piece|
            seconds += piece.to_f.round * multipliers.shift
          end
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