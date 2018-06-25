require 'active_support/all'
require 'reverse_markdown'

require_relative 'importer'

class Transformer

  class << self
    attr_reader :fields

    def field_map(map = {})
      (@fields = map.symbolize_keys).each do |k,v|
        self.class_eval do
          define_method("transformed_#{k}") do
            value = attributes[v.try(:to_sym)]
            k.to_s.ends_with?('_at') ? Date.parse(value) : value
          end
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

  def transform!
    field_map.each do |k,v|
      self.importable_data[k] = send("transformed_#{k}")
    end
  end

  def import!
    transform! if importable_data.blank?
    entry = Importer.create_entry(content_type, importable_data)
    entry.publish
    Logger.write('.', :green)
    sleep 0.15
    entry
  end

  def html_to_markdown(html)
    ReverseMarkdown.convert(html)
  end

  private

  def field_map
    self.class.fields
  end

end
