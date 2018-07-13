# Example Usage:
#
# Youtube.fetch_videos(%w{UC5w5QDnJIpeJR_KnLZSEg1Q UCEdRBpSpVgfuybR3lzgxa-Q UCHpWI1liDspGqKMFWGpFi1w UChU7KxJdQ2Gt7cCsBbfE6vQ UCmMySSzKknjgAVVCOPXu_qg})

# 32 + 996 + 145 + 20 + 465 = 1658

require 'rest-client'
require_relative 'logger'
require_relative 'importer'

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

    def import_videos
      self.videos = JSON.parse(File.read(video_file_path))
      videos.each do |video|
        still = Importer.create_asset(video['snippet']['thumbnails']['high']['url'], video['snippet']['title'])
        entry = Video.new(
          title: video['snippet']['title'],
          description: video['snippet']['description'],
          source_url: "https://www.youtube.com/watch?v=#{video['id']['videoId']}",
          published_at: DateTime.parse(video['snippet']['publishedAt']),
          still: still
        )
        entry.import!
      end
      Importer.process_assets
      Importer.publish_assets
    end

    private

      def videos_in_channel(channel_id, options = {})
        params = {
          key: ENV['GOOGLE_API_KEY'],
          channelId: channel_id,
          part: 'snippet,id',
          maxResults: 50,
          order: 'date',
          publishedAfter: '2017-07-01T00:00:00Z'
        }
        params[:pageToken] = options[:page_token] if options[:page_token]
        res = RestClient.get('https://www.googleapis.com/youtube/v3/search', params: params)
        body = JSON.parse(res.body)
        Logger.write("Adding #{body['items'].size} videos from channel #{channel_id}.\n")
        self.videos.concat(body['items'])
        if body['nextPageToken'] && body['items'].size > 0
          Logger.write("Fetching next page: #{body['nextPageToken']} ...\n")
          return videos_in_channel(channel_id, page_token: body['nextPageToken'])
        end
        videos
      end

      def video_file_path
        File.expand_path('../tmp/youtube-videos.json', __dir__)
      end

      def write_videos
        videos.uniq!
        File.open(video_file_path, 'w+') { |f| f.write(videos.to_json) }
        videos
      end
  end

end
