require 'active_support/all'

require_relative 'importer'

class Transformer

  class << self
    attr_reader :fields

    def field_map(map = {})
      (@fields = map.symbolize_keys).each do |k,v|
        self.class_eval do
          define_method("transformed_#{k}") { attributes[v.try(:to_sym)] }
        end
      end
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
    field_map.each do |k,v|
      self.importable_data[k] = send("transformed_#{k}")
    end
  end

  def import!
    transform! if importable_data.blank?
    entry = Importer.create_entry(content_type, importable_data)
    entry.publish
  end

end
