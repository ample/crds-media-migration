require_relative 'exporter'
require_relative 'importer'
require_relative 'transformer'

require_relative '../models/message'
require_relative '../models/song'
require_relative '../models/series'
require_relative '../models/video'

class Migrator

  def self.migrate
    # series_data = Exporter.get_entries('/series')
    # series = Series.new(series_data.first)
    # series.transform!
    # series.import!

    # videos_data = Exporter.get_entries('/videos')
    # video = Video.new(videos_data.first)
    # video.transform!
    # video.import!

    music_data = Exporter.get_entries('/music')
    song = Song.new(music_data.first)
    song.transform!
    song.import!
  end

end
