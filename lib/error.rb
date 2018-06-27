require 'fileutils'

class Error

  class << self

    def write(data)
      verify_tmp_dir
      File.open(error_file, 'a+') { |f| f.write("#{[data].to_yaml}\n") }
    end

    def purge!
      File.delete(error_file) if File.exist?(error_file)
    end

    private

      def error_file
        @error_file ||= File.expand_path('../tmp/errors.yml', __dir__)
      end

      def verify_tmp_dir
        tmp_dir = File.expand_path('../tmp', __dir__)
        FileUtils.mkdir_p(tmp_dir) unless Dir.exist?(tmp_dir)
      end
  end

end
