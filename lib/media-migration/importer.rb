require 'dotenv/load'

class Importer

  attr_reader :env

  def initialize
    client = Contentful::Management::Client.new(ENV['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN'])
    @env = client.environments(ENV['CONTENTFUL_SPACE_ID']).find(ENV['CONTENTFUL_ENV'])
  end

  def create_entry(content_type, data)
    content_type = env.content_types.find(content_type)
    content_type.entries.create(data)
  end

end