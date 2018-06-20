require_relative 'exporter'
require_relative 'importer'
require_relative 'transformer'

require_relative '../models/message'
require_relative '../models/series'
require_relative '../models/video'

class Migrator

  def self.migrate
    series_data = Exporter.get_entries('/series')
    series = Series.new(series_data.first)
    series.transform!
    series.import!
  end

end
