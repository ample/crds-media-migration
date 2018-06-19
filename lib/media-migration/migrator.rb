module MediaMigration
  class Migrator

    # attr_accessor :name

    # def initialize(name = nil)
    #   @name = name
    # end

    def self.migrate! # (name = nil)
      # @name ||= name
      # raise ArgumentError.new("Missing required attribute: name") if name.blank?

      series = Exporter.get_entries('/series')

      field_map = {
        title: 'title',
        slug_abc: 'slug'
      }
      data = DataTransformer.transform(series, field_map)

      importer = Importer.new
      importer.create_entry('series', data.first)
    end

  end
end
