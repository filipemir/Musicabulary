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



class Genius
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
    get(
      '/artists/' + artist_id.to_s + '/songs'
    )
  end

  private

  def get(url, params = {})
    self.class.get(
      url + '?access_token=' + ENV['GENIUS_TOKEN'],
      query: params
    )
  end

end

genius = Genius.new
# hop_along_id = genius.find_artist_id('hop along')
# hop_along = genius.artist_info(hop_along_id) # Does not work
# genius.get('/artists/37695') # Works
 
# binding.pry