require_relative 'exporter'
require_relative 'importer'
require_relative 'logger'
require_relative 'redirector'
require_relative 'transformer'

require_relative '../models/message'
require_relative '../models/song'
require_relative '../models/series'
require_relative '../models/video'

class Migrator

  def self.migrate(*models)
    Redirector.purge!
    models.each do |model|
      Exporter.get_entries("/#{model.to_s.downcase.pluralize}").first(10).each do |data|
        obj = model.to_s.classify.constantize.new(data)
        obj.transform!
        obj.import!
        obj.write_redirect!
      end
    end
  end

end
