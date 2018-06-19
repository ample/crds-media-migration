require 'active_support/all'
require 'contentful/management'
require 'dotenv/load'
require 'mime/types/full'

class Importer

  class << self
    def create_entry(content_type, data)
      content_type = env.content_types.find(content_type)
      content_type.entries.create(data)
    end

    def create_asset(url)
      image_file = Contentful::Management::File.new
      image_file.properties[:contentType] = MIME::Types.type_for(url).first.try(:to_s)
      image_file.properties[:fileName] = File.basename(url)
      image_file.properties[:upload] = url
      title = File.basename(url, '.*').titleize
      asset = env.assets.create(title: title, file: image_file)
      asset.process_file
      asset.publish
    end

    private

    def client
      @client ||= Contentful::Management::Client.new(ENV['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN'])
    end

    def env
      @env ||= client.environments(ENV['CONTENTFUL_SPACE_ID']).find(ENV['CONTENTFUL_ENV'])
    end
  end

end
