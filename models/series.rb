require_relative 'message'
require_relative 'video'

class Series < Transformer

  field_map title: 'title',
            slug: nil,
            image: nil,
            description: 'description',
            starts_at: 'startDate',
            ends_at: 'endDate',
            published_at: nil,
            videos: nil

  def transformed_slug
    attributes[:title].parameterize
  end

  def transformed_description
    html_to_markdown(attributes[:description])
  end

  def transformed_image
    return attributes[:image] if attributes[:image].is_a?(Contentful::Management::Asset)
    return nil unless attributes[:image].present? && attributes[:image][:filename].present?
    Importer.create_asset(attributes[:image][:filename])
  end

  def transformed_published_at
    Date.parse(attributes[:startDate])
  end

  def transformed_videos
    ([create_trailer_video] + (@messages = create_messages)).sort_by { |x| x.fields[:published_at] }
  end

  def import!
    series = super
    @messages.each { |msg| msg.update(series: series) }
  end

  private

  def create_trailer_video
    return nil if attributes[:trailerLink].blank?

    video = Video.new(
      title: "#{attributes[:title]} (Trailer)",
      still: importable_data[:image],
      source_url: attributes[:trailerLink],
      published_at: importable_data[:published_at]
    )
    video.transform!
    video.import!
  end

  def create_messages
    attributes[:messages].map do |message|
      message = Message.new(message)
      message.transform!
      message.import!
    end
  end

end
