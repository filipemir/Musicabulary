require 'httparty'
require 'json'
require 'dotenv'
require 'pry'
require 'discogs-wrapper'

Dotenv.load

# wrapper = Discogs::Wrapper.new("argot", user_token: ENV['DISCOGS_TOKEN'])
# results = wrapper.search("Laura Stevenson")



# artist_id = 2002202
# artist = wrapper.get_artist(artist_id)
# releases = wrapper.get_artists_releases(artist_id, sort: 'year', sort_order: 'asc', per_page: 1000)
# release = wrapper.get_release(4994081)
# master = wrapper.get_release(606966)
