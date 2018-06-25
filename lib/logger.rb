class Logger

  class << self
    def write(str, color = :white)
      STDOUT.write(colorize(str, color.to_sym))
    end

    private

      def colors
        @colors ||= {
          blue: 34,
          green: 32,
          light_blue: 36,
          pink: 35,
          red: 31,
          white: 256,
          yellow: 33
        }
      end

      def colorize(str, color_code)
        "\e[#{colors[color_code]}m#{str}\e[0m"
      end
  end

end
