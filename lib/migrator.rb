require_relative 'exporter'
require_relative 'importer'
require_relative 'transformer'

require_relative '../models/message'
require_relative '../models/song'
require_relative '../models/series'
require_relative '../models/video'

class Migrator

  def self.migrate
    series_data = Exporter.get_entries('/series')
    # series = Series.new(series_data.first)
    # series.transform!
    # series.import!
    series_data.each do |data|
      series = Series.new(data)
      series.transform!
      series.import!
    end

    videos_data = Exporter.get_entries('/videos')
    # video = Video.new(videos_data.first)
    # video.transform!
    # video.import!
    videos_data.each do |data|
      video = Video.new(data)
      video.transform!
      video.import!
    end

    music_data = Exporter.get_entries('/music')
    # song = Song.new(music_data.first)
    # song.transform!
    # song.import!
    music_data.each do |data|
      song = Song.new(data)
      song.transform!
      song.import!
    end
  end

end
