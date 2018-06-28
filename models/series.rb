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
    ([create_trailer_video] + (@messages = create_messages)).reject(&:blank?).sort_by { |x| x.fields[:published_at] }
  end

  def write_redirect!
    return unless attributes[:id].present?
    Redirector.write("/series/#{attributes[:id]}/*", "/series/#{importable_data[:slug]}")
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
    video.write_redirect!
    video.import!
  end

  def create_messages
    attributes[:messages].map do |message|
      message = Message.new(message)
      message.transform!
      src = "/message/#{message.attributes[:id]}/*"
      dest = "/series/#{importable_data[:slug]}/#{message.importable_data[:slug]}"
      Redirector.write(src, dest)
      message.import!
    end
  end

end
