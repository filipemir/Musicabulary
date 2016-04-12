require 'httparty'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load

req = HTTParty.get(
  'https://api.genius.com/artists/16775',
  query: { access_token: ENV['GENIUS_TOKEN'] }
)

hop_along = HTTParty.get(
  'https://api.genius.com/search',
  query: { q: 'Hop Along artist', access_token: ENV['GENIUS_TOKEN'] }
)

hop_along2 = HTTParty.get(
  'https://api.genius.com/search?access_token=' + ENV['GENIUS_TOKEN'],
  query: { q: 'Hop Along' }
)



class GeniusAPI
  include HTTParty
 # debug_output $stdout

  base_uri 'https://api.genius.com'

  def search(search_terms)
    get('/search', { q: search_terms })
  end

  def find_artist_id(artist_name)
    search_results = search(artist_name)
    status_code = search_results['meta']['status']
    top_result = search_results['response']['hits'].first
    if status_code == 200
      top_result['result']['primary_artist']['id']
    else
      false
    end
  end

  def artist_info(artist_id)
    get('/artists/' + artist_id.to_s)
  end

  def artist_songs(artist_id)
    get('/artists/' + artist_id.to_s + '/songs')
  end

  def get_song(id)
    get('/songs/' + id.to_s)
  end

  private

  def get(url, params = {})
    self.class.get(
      url + '?access_token=' + ENV['GENIUS_TOKEN'],
      query: params
    )
  end

end

#vgenius = Genius.new
# hop_along_id = genius.find_artist_id('hop along')
# hop_along = genius.artist_info(hop_along_id) # Does not work
# genius.get('/artists/37695') # Works
 


# search_hits = genius.search(track.artist + ' ' + track.title + ' ' + track.record)

# track_id = search_hits['response']['hits'].each do |hit|
#   type = hit['type'].strip
#   title = hit['result']['title'].strip
#   hit_artist = hit['result']['primary_artist']['name'].strip
#   if hit_artist == artist.name.strip && type == 'song' && title == track.title.strip
#     break hit['result']['id']
#   else
#     false
#   end
# end

