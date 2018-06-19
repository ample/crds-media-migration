class Series < Transformer

  field_map title: 'title', slug: nil, image: nil

  def transformed_slug
    attributes[:title].parameterize
  end

  def transformed_image
    Importer.create_asset(attributes[:image][:filename])
  end

end
