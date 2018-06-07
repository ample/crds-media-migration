require 'httparty'
require 'dotenv/load'

class Import
  include HTTParty

  attr_accessor :space_id

  base_uri 'cdn.contentful.com'

  def initialize()
    @space_id = ENV['CONTENTFUL_SPACE_ID']
  end

  def create_entry(json)
    self.class.post("/spaces/#{@space_id}/entries", { body: json })
  end

  def run(arr)
    arr.each do | entry |
      create_entry(entry)
    end
  end
end