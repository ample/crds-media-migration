require_relative 'error'
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

  def self.migrate(models = {})
    models.each do |endpoint, class_name|
      Exporter.get_entries(endpoint).each do |data|
        obj = class_name.constantize.new(data)
        obj.transform!
        obj.import!
        obj.write_redirect!
      end
    end
  end

end
