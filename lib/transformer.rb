require 'active_support/all'

class Transformer

  class << self
    attr_reader :fields

    def field_map(map = {})
      @fields = map.symbolize_keys
    end
  end

  attr_accessor :attributes, :importable_data, :content_type

  def initialize(attributes = {})
    @attributes = attributes.deep_symbolize_keys
    @importable_data = {}
    @content_type = self.class.name.singularize.underscore
  end

  def field_map
    self.class.fields
  end

  def transform!
    field_map.each { |k,v| send("transform_#{k}") }
  end

  def import!
    transform! if importable_data.blank?
    Importer.create_entry(content_type, importable_data)
  end

  def method_missing(m, *args, &block)
    super unless m.to_s.start_with?('transform_')
    dest_field = m.to_s.remove('transform_').to_sym
    src_field = field_map[dest_field].to_sym
    self.importable_data[dest_field] = attributes[src_field]
  end

end
