require 'contentful/management'
require 'mime/types/full'
require 'rest_client'
require_relative 'logger'

class MessageAssetMigrator

  attr_accessor :cf_messages, :ss_messages, :cf_assets, :cf_errors

  def run!
    fetch_ss_messages
    fetch_cf_messages
    import_media_files
    publish_cf_assets
    true
  end

  private

    def fetch_ss_messages
      Logger.write("Fetching message data from SilverStripe ...\n")
      response = RestClient.get('https://www.crossroads.net/proxy/content/api/series')
      series = JSON.parse(response.body).dig('series')
      @ss_messages = series.flat_map { |s| s.dig('messages') }.reject(&:nil?)
      Logger.write("Done! Retrieved #{ss_messages.size} messages.\n")
    end

    def fetch_cf_messages(skip = 0)
      self.cf_messages ||= []
      Logger.write("Fetching message data from Contentful ...\n") if skip == 0
      messages = contentful.entries.all(content_type: 'message', limit: 1000, skip: skip)
      @cf_messages.concat(messages.to_a)
      if messages.size == 1000
        fetch_cf_messages(cf_messages.size)
      else
        Logger.write("Done! Retrieved #{cf_messages.size} eligible messages.\n")
        @cf_messages.select! { |m| m.fields[:published_at].present? }
      end
    end

    def import_media_files
      cf_assets ||= []
      ss_messages.each do |ss_msg|
        video_url = ss_msg.dig('messageVideo', 'source', 'filename')
        audio_url = ss_msg.dig('messageAudio', 'source', 'filename')
        next if ss_msg['date'].blank? || (video_url.blank? && audio_url.blank?)
        date = Date.parse(ss_msg['date'])
        cf_msg = cf_messages.detect { |m| date == Date.parse(m.fields[:published_at]) }
        next if cf_msg.blank?
        if video_url
          if video_file = create_asset(video_url)
            video_file.process_file
            cf_msg.video_file = video_file
            cf_assets << video_file
          else
            @cf_errors << video_url
          end
        end
        if audio_url
          if audio_file = create_asset(audio_url)
            audio_file.process_file
            cf_msg.audio_file = audio_file
            cf_assets << audio_file
          else
            @cf_errors << audio_url
          end
        end
        cf_msg.save
        cf_msg.publish
        log_and_wait
      end
    end

    def publish_cf_assets
      cf_assets.map { |a| a.publish }
    end

    def create_asset(url)
      return nil if url.nil?
      image_file = Contentful::Management::File.new
      image_file.properties[:contentType] = MIME::Types.type_for(url).first.try(:to_s)
      image_file.properties[:fileName] = File.basename(url)
      image_file.properties[:upload] = url
      title = File.basename(url, '.*').titleize if title.nil?
      asset = contentful.assets.create(title: title, file: image_file)
      unless asset.is_a?(Contentful::Management::Asset)
        puts "Error creating asset: #{url}"
        log_and_wait(:red)
        return nil
      end
      log_and_wait
      asset
    end

    def contentful
      @contentful ||= begin
        client = Contentful::Management::Client.new(ENV['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN'])
        client.environments(ENV['CONTENTFUL_SPACE_ID']).find(ENV['CONTENTFUL_ENV'])
      end
    end

    def log_and_wait(color = :green)
      Logger.write('.', color)
      sleep 0.11
    end

end
