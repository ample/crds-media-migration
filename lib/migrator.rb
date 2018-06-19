require_relative 'exporter'
require_relative 'importer'
require_relative 'transformer'

require_relative '../models/series'

class Migrator

  def self.migrate # (name = nil)
    # @name ||= name
    # raise ArgumentError.new("Missing required attribute: name") if name.blank?

    series_data = Exporter.get_entries('/series')

    series = Series.new(series_data.first)
    series.transform!
    # binding.pry
    series.import!

    # all_series = series_data.map { |data| Series.new(data) }
    # series = all_series.first

    # field_map = {
    #   title: 'title',
    #   slug_abc: 'slug'
    # }
    # data = Transformer.transform(series, field_map)

    # Importer.create_entry('series', data.first)
  end

end
