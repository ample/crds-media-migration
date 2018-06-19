class Series < Transformer

  field_map title: 'title',
            slug: nil,
            # image: nil, # TODO: Add this back when the other attrs are buttoned up
            description: 'description',
            starts_at: 'startDate',
            ends_at: 'endDate',
            published_at: nil

  # TODO: Create associated messages/videos first and then finish creating this
  # series.

  def transformed_slug
    attributes[:title].parameterize
  end

  def transformed_description
    html_to_markdown(attributes[:description])
  end

  def transformed_image
    binding.pry
    Importer.create_asset(attributes[:image][:filename])
  end

  def transformed_published_at
    DateTime.now
  end

end
