class Series < Transformer

  field_map title: 'title',
            slug: nil,
            # image: nil, # TODO: Add this back when the other attrs are buttoned up
            description: 'description',
            starts_at: 'startDate',
            ends_at: 'endDate',
            something_else: nil

  # TODO: Create associated messages/videos first and then finish creating this
  # series.

  # TODO: Parse HTML to markdown for description.

  # TODO: Revise field map so:
  #
  #   - string --> field value
  #   - :symbol --> method name
  #   - { proc(?) } --> processes on demand

  # def transformed_slug
  #   attributes[:title].parameterize
  # end

  def transformed_description
    html_to_markdown(attributes[:description])
  end

  def transformed_image
    binding.pry
    raise '---'
    Importer.create_asset(attributes[:image][:filename])
  end

  def transformed_something_else
    binding.pry
  end

end
