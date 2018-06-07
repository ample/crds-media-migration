require 'import'
require 'export'

class Migrate

  attr_accessor :import, :export

  def initialize()
    @import = Import.new
    @export = Export.new
  end

end