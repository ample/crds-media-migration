require 'httparty'

class Export
  include HTTParty

  base_uri 'www.crossroads.net/proxy/content/api/'

  def initialize()
    @options = {}
  end

  def series
    # get the series and loop through each one
    # render out the json output for each entry
    # return an array of all json for all things to push to contentful

    # series should have: title, slug, image, starts_at, ends_at, description, tags, trailer_url
    # following is the format the above should return:
    # {
    #   "fields": {
    #     "title": {
    #       "en-US": "Hello, World!"
    #     },
    #     "body": {
    #       "en-US": "Bacon is healthy!"
    #     }
    #   }
    # }
  end

  private

  def get_series
    self.class.get('/series', @options) # ['series']
  end

end