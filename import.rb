require 'httparty'

class Import
  include HTTParty

  base_uri 'www.crossroads.net/proxy/content/api/'

  def initialize()
    @options = { }
  end

  def series

  end

  private
    def get_series
      self.class.get('/series', @options)
    end
end