class Message < Transformer

  @color = :white

  field_map title: 'title',
            slug: nil,
            description: 'description',
            published_at: 'date',
            source_url: nil,
            audio_source_url: nil,
            image: nil,
            tags: nil,
            program: nil

  def transformed_slug
    attributes[:title].parameterize
  end

  def transformed_description
    return nil unless attributes[:description].present?
    html_to_markdown(attributes[:description])
  end

  def transformed_source_url
    return nil unless attributes[:messageVideo].present? && attributes[:messageVideo][:serviceId].present?
    "https://youtu.be/#{attributes[:messageVideo][:serviceId]}"
  end

  def transformed_audio_source_url
    return nil unless attributes[:messageAudio].present? && attributes[:messageAudio][:serviceId].present?
    "https://soundcloud.com/crdschurch/#{attributes[:messageAudio][:serviceId]}"
  end

  def transformed_image
    return attributes[:image] if attributes[:image].is_a?(Contentful::Management::Asset)
    return nil unless attributes[:messageVideo].present? &&
                      attributes[:messageVideo][:still].present? &&
                      attributes[:messageVideo][:still][:filename].present?
    Importer.create_asset(attributes[:messageVideo][:still][:filename])
  end

  def transformed_tags
    return [] unless attributes[:tags].present?
    attributes[:tags].collect { |t| t[:title] }.sort
  end

  def transformed_program
    return attributes[:program] if attributes[:program].is_a?(Contentful::Management::Asset)
    return nil unless attributes[:program].present? && attributes[:program][:filename].present?
    Importer.create_asset(attributes[:program][:filename])
  end

end
