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
    return attributes[:still] if attributes[:still].is_a?(Contentful::Management::Asset)
    return nil unless attributes[:still].present? && attributes[:still][:filename].present?
    Importer.create_asset(attributes[:still][:filename])
  end

  def transformed_source_url
    return attributes[:source_url] if attributes[:source_url].present?
    "https://youtu.be/#{attributes[:serviceId]}"
  end

  def transformed_published_at
    return attributes[:published_at] if attributes[:published_at].present?
    return DateTime.parse(attributes[:created]) if attributes[:created].present?
    DateTime.now
  end

  def write_redirect!
    return unless attributes[:id].present?
    Redirector.write("/media/#{attributes[:id]}/*", "/videos/#{importable_data[:slug]}")
  end

end
