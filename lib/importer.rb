require 'active_support/all'
require 'contentful/management'
require 'dotenv/load'
require 'mime/types/full'

class Importer

  class << self

    # ---------------------------------------- | Creating

    def create_asset(url)
      return nil if url.nil?
      image_file = Contentful::Management::File.new
      image_file.properties[:contentType] = MIME::Types.type_for(url).first.try(:to_s)
      image_file.properties[:fileName] = File.basename(url)
      image_file.properties[:upload] = url
      title = File.basename(url, '.*').titleize
      asset = env.assets.create(title: title, file: image_file)
      unless asset.is_a?(Contentful::Management::Asset)
        Error.write(content_type: 'asset', data: { url: url }, error: JSON.parse(asset.response.raw.body))
        log_and_wait :red
        return asset
      end
      log_and_wait :blue
      asset
    end

    def create_entry(content_type, data)
      content_type = content_types.find(content_type)
      entry = content_type.entries.create(data)
      unless entry.is_a?(Contentful::Management::DynamicEntry)
        Error.write(content_type: content_type, data: data, error: JSON.parse(entry.response.raw.body))
        log_and_wait :red
        return entry
      end
      log_and_wait
      entry
    end

    # ---------------------------------------- | Processing

    def process_assets
      page_1 = env.assets.all(limit: 1000)
      page_2 = page_1.next_page
      page_3 = page_2.next_page
      [page_1, page_2, page_3].each do |page|
        page.to_a.reject(&:published?).each do |asset|
          pub = asset.process_file
          unless pub.is_a?(Contentful::Management::Asset)
            Error.write(content_type: 'asset', data: {}, error: JSON.parse(pub.response.raw.body))
            log_and_wait :red
            next
          end
          log_and_wait :blue
        end
      end
    end

    # ---------------------------------------- | Publishing

    def publish_assets
      page_1 = env.assets.all(limit: 1000)
      page_2 = page_1.next_page
      page_3 = page_2.next_page
      [page_1, page_2, page_3].each do |page|
        page.to_a.reject(&:published?).each do |asset|
          pub = asset.publish
          unless pub.is_a?(Contentful::Management::Asset)
            Error.write(content_type: 'asset', data: {}, error: JSON.parse(pub.response.raw.body))
            log_and_wait :red
            next
          end
          log_and_wait :blue
        end
      end
    end

    def publish_entries(content_type = nil)
      scope = content_type.nil? ? env : content_types.find(content_type)
      page_1 = scope.entries.all(limit: 1000)
      page_2 = page_1.next_page
      page_3 = page_2.next_page
      [page_1, page_2, page_3].each do |page|
        page.to_a.reject(&:published?).each do |entry|
          publish_entry(entry)
        end
      end
    end

    # ---------------------------------------- | Unpublishing

    def unpublish_content
      %i[entries assets].each do |type|
        page_1 = env.send(type).all(limit: 1000)
        page_2 = page_1.next_page
        page_3 = page_2.next_page
        [page_1, page_2, page_3].each do |page|
          page.select(&:published?).each do |obj|
            obj.unpublish
            log_and_wait(type == :assets ? :blue : :green)
          end
        end
      end
    end

    def unpublish_entries(content_type = nil)
      scope = content_type.nil? ? env : content_types.find(content_type)
      scope.entries.all(limit: 1000).select(&:published?).each do |entry|
        entry.unpublish
        log_and_wait
      end
    end

    # ---------------------------------------- | Deleting

    def delete_drafts
      %i[entries assets].each do |type|
        env.send(type).all(limit: 1000).reject(&:published?).each do |obj|
          obj.destroy
          log_and_wait(type == :assets ? :blue : :green)
        end
      end
    end

    def deactivate_content_types
      content_types.all.to_a.each do |content_type|
        content_type.deactivate
        log_and_wait
      end
    end

    def delete_content_types
      content_types.all.to_a.each do |content_type|
        content_type.destroy
        log_and_wait
      end
    end

    # ---------------------------------------- | Migrations

    def create_migration_records
      return false if content_types.find('migrations').entries.all.size > 0
      6.times { |idx| create_entry(:migrations, version: "2018061400000#{idx}".to_i) }
    end

    private

    def client
      @client ||= Contentful::Management::Client.new(ENV['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN'])
    end

    def env
      @env ||= client.environments(ENV['CONTENTFUL_SPACE_ID']).find(ENV['CONTENTFUL_ENV'])
    end

    def content_types
      @content_types ||= env.content_types
    end

    def log_and_wait(color = :green)
      Logger.write('.', color)
      sleep 0.11
    end

    def publish_entry(entry)
      pub = entry.publish
      unless pub.is_a?(Contentful::Management::Entry)
        return log_and_wait(:red) unless pub.message.include?('slug')
        entry.update(slug: "#{entry.fields[:slug]}-#{entry.id}")
        return publish_entry(entry)
      end
      log_and_wait
    end
  end

end
