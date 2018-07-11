# Example Usage:
#
# channels_list = %w{UC5w5QDnJIpeJR_KnLZSEg1Q UCEdRBpSpVgfuybR3lzgxa-Q UCHpWI1liDspGqKMFWGpFi1w UChU7KxJdQ2Gt7cCsBbfE6vQ UCmMySSzKknjgAVVCOPXu_qg}

# Youtube.fetch_videos(channels_list)

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

      def videos_in_channel(channel_id, page_token = nil)
        params = {
          key: ENV['GOOGLE_API_KEY'],
          channelId: channel_id,
          part: 'snippet,id',
          maxResults: 50
        }
        params[:pageToken] = page_token if page_token
        res = RestClient.get('https://www.googleapis.com/youtube/v3/search', params: params)
        body = JSON.parse(res.body)
        Logger.write("Adding #{body['items'].size} videos from channel #{channel_id}.\n")
        self.videos.concat(body['items'])
        if body['nextPageToken']
          Logger.write("Fetching next page: #{body['nextPageToken']} ...\n")
          return videos_in_channel(channel_id, body['nextPageToken'])
        end
        videos
      end

      def write_videos
        file_path = File.expand_path('../tmp/youtube-videos.json', __dir__)
        File.open(file_path, 'w+') { |f| f.write(videos.to_json) }
        videos
      end
  end

end
