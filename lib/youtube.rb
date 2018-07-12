# Example Usage:
#
# Youtube.fetch_videos(%w{UC5w5QDnJIpeJR_KnLZSEg1Q UCEdRBpSpVgfuybR3lzgxa-Q UCHpWI1liDspGqKMFWGpFi1w UChU7KxJdQ2Gt7cCsBbfE6vQ UCmMySSzKknjgAVVCOPXu_qg})

# 32 + 996 + 145 + 20 + 465 = 1658

require 'rest-client'
require_relative 'logger'

class Youtube

  class << self
    attr_accessor :videos

    def fetch_videos(channel_ids)
      self.videos = []
      channel_ids.each do |channel_id|
        videos_in_channel(channel_id)
      end
      write_videos
    end

    private

      def videos_in_channel(channel_id, options = {})
        params = {
          key: ENV['GOOGLE_API_KEY'],
          channelId: channel_id,
          part: 'snippet,id',
          maxResults: 50,
          order: 'date'
        }
        params[:pageToken] = options[:page_token] if options[:page_token]
        params[:publishedBefore] = options[:published_before] if options[:published_before]
        res = RestClient.get('https://www.googleapis.com/youtube/v3/search', params: params)
        body = JSON.parse(res.body)
        Logger.write("Adding #{body['items'].size} videos from channel #{channel_id}.\n")
        self.videos.concat(body['items'])
        if options[:published_before].nil? && body['items'].size == 0
          publish_date = options[:last_video]['snippet']['publishedAt']
          Logger.write("--- Videos before by #{publish_date} ---\n")
          binding.pry
          videos_in_channel(channel_id, published_before: publish_date)
          # %w{date rating relevance title videoCount viewCount}.each do |order_method|
          #   Logger.write("--- Ordering by #{order_method} ---\n")
          #   videos_in_channel(channel_id, nil, order_method)
          # end
        elsif body['nextPageToken'] && body['items'].size > 0
          Logger.write("Fetching next page: #{body['nextPageToken']} ...\n")
          return videos_in_channel(
            channel_id,
            page_token: body['nextPageToken'],
            published_before: options[:published_before],
            last_video: body['items'].last
          )
        end
        videos
      end

      def write_videos
        file_path = File.expand_path('../tmp/youtube-videos.json', __dir__)
        videos.uniq!
        File.open(file_path, 'w+') { |f| f.write(videos.to_json) }
        videos
      end
  end

end
