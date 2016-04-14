require 'httparty'
require 'json'
require 'dotenv'
require 'pry'
require 'discogs-wrapper'

Dotenv.load

module Discogs
  def self.included(receiving_class)
    receiving_class.send :include, HTTParty
    receiving_class.send :base_uri, 'https://api.discogs.com/'
  end

  def discogs_query(path, params = {})
    params = params.merge(token: ENV['DISCOGS_TOKEN'])
    self.class.get(path, query: params)
  end

  def get_artist_id
    search_results = discogs_query('/database/search', q: name)['results']
    search_results.each do |result|
      title = result['title']
      type = result['type']
      id = result ['id']
      return id if title == name && type == 'artist'
    end
    false
  end

  def get_artist_records(page)
    discogs_query(
      '/artists/' + id.to_s + '/releases',
      sort: 'year',
      sort_order: 'asc',
      page: page,
      per_page: 100, 
    )
  end

  def get_record_tracks(type, id, record_title)
    result = []
    record = discogs_query('/' + type + 's/' + id.to_s)
    record['tracklist'].each do |track|
      result << Song.new(
        track['title'], 
        record['artists'].first['name'],
        record_title
      )
    end
    result
  end
end

# wrapper = Discogs::Wrapper.new("argot", user_token: ENV['DISCOGS_TOKEN'])
# results = wrapper.search("Laura Stevenson")



# artist_id = 2002202
# artist = wrapper.get_artist(artist_id)
# releases = wrapper.get_artists_releases(artist_id, sort: 'year', sort_order: 'asc', per_page: 1000)
# release = wrapper.get_release(4994081)
# master = wrapper.get_release(606966)

# HTTParty.get(
#   base_uri + 'database/search',
#   query: { q: 'Laura+Stevenson', token:  ENV['DISCOGS_TOKEN'] }
# )