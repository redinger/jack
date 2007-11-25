$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'aws-s3', 'lib')
require 'aws/s3'

module Jack
  module Tasks
    module S3
      def store_in_s3(name, filename, bucket = nil, options = {})
        if bucket.is_a?(Hash)
          options = bucket
          bucket = nil
        end
        bucket ||= default_s3_bucket
        logger.info("[S3] Storing #{name} in #{bucket} from #{filename}")
        AWS::S3::S3Object.store name, open(filename), bucket, options
      end
      
      def download_from_s3(s3_name, bucket = nil)
        bucket ||= default_s3_bucket
        logger.info("[S3] Downloading #{s3_name} from #{bucket}")
        full_path = File.join(s3_working_path, s3_name)
        name      = File.basename(full_path)
        dir       = File.dirname(full_path)
        FileUtils.mkdir_p dir
        Dir.chdir dir do
          open name, 'w' do |file|
            AWS::S3::S3Object.stream s3_name, bucket do |chunk|
              file.write chunk
            end
          end
        end
        if block_given?
          yield full_path
          File.delete full_path
        end
        full_path
        
      end
      
      def delete_from_s3(name, bucket = nil)
        bucket ||= default_s3_bucket
        logger.info("[S3] Deleting #{name} from #{bucket}")
        AWS::S3::S3Object.delete name, bucket
      end
      
      def default_s3_bucket
        @default_s3_bucket
      end
      
      def s3_working_path
        @s3_working_path
      end
    end
  end
end