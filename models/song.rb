class Song < Transformer

  @color = :yellow

  field_map title: 'title',
            slug: nil,
            description: 'description',
            image: nil,
            soundcloud_url: nil,
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

  def transformed_soundcloud_url
    return nil unless attributes[:serviceId].present?
    "https://soundcloud.com/crdschurch/#{attributes[:serviceId]}"
  end

  def transformed_published_at
    return attributes[:published_at] if attributes[:published_at].present?
    return DateTime.parse(attributes[:created]) if attributes[:created].present?
    DateTime.now
  end

end
