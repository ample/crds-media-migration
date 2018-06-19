require 'hashie'

class Transformer

  def self.transform(data, config)
    transformed_data = []

    data.each do |obj|
      obj = Hashie::Mash.new(obj)
      new_obj = {}

      config.each do |k, v|
        new_obj[k] = obj.send(v)
      end

      transformed_data << new_obj
    end

    transformed_data
  end

end
