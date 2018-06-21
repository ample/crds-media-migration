require 'httparty'
require 'json'

class Exporter

  include HTTParty

  base_uri 'www.crossroads.net/proxy/content/api/'

  def self.get_entries(path, data_key = nil)
    response = get(path)
    body = JSON.parse(response.body)
    body[data_key || body.keys.first]
  end

end
