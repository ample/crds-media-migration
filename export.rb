require 'httparty'
require 'dotenv/load'

class Export
  include HTTParty

  attr_accessor :space_id

  base_uri 'cdn.contentful.com'

  def initialize()
    @space_id = ENV['CONTENTFUL_SPACE_ID']
  end

  def create_entry(entry)
    self.class.post("/spaces/#{@space_id}/entries")
  end
end