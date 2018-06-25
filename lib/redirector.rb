require 'fileutils'

class Redirector

  class << self

    def write(src, dest)
      verify_tmp_dir
      File.open(redirect_file, 'a+') { |f| f.write("#{src},#{dest}\n") }
    end

    def purge!
      File.delete(redirect_file) if File.exist?(redirect_file)
    end

    private

      def redirect_file
        @redirect_file ||= File.expand_path('../tmp/redirects.csv', __dir__)
      end

      def verify_tmp_dir
        tmp_dir = File.expand_path('../tmp', __dir__)
        FileUtils.mkdir_p(tmp_dir) unless Dir.exist?(tmp_dir)
      end
  end

end
