class Video < Transformer

  field_map title: 'title',
            slug: nil,
            description: 'description',
            image: nil,
            source_url: 'source_url',
            published_at: nil

  def transformed_slug
    attributes[:title].parameterize
  end

  def transformed_description
    return nil unless attributes[:description].present?
    html_to_markdown(attributes[:description])
  end

  def transformed_image
    return attributes[:image] if attributes[:image].is_a?(Contentful::Management::Asset)
    return nil unless attributes[:image].present? && attributes[:image][:filename].present?
    Importer.create_asset(attributes[:image][:filename])
  end

  def transformed_published_at
    attributes[:published_at] || DateTime.now
  end

end
