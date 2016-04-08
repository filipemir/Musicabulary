require 'httparty'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load

class LastFM
  include HTTParty
  # debug_output $stdout

  attr_reader :username

  base_uri 'http://ws.audioscrobbler.com/2.0/'

  def user_info(username)
    result = get(
      'method=user.getinfo' + \
      '&user=' + username
    )
    result['user']
  end

  def user_avatar(username)
    images = user_info(username)['image']
    image = images.select { |image| image['size'] == 'large' }
    image = image[0]['#text']
    ['', nil].include?(image) ? 'default_avatar.jpg' : image
  end

  def user_top_artists(username, timeframe = "overall", number = 50)
    result = get(
      'method=user.gettopartists' + \
      '&user=' + username + \
      '&period=' + timeframe + \
      '&limit=' + number.to_s
    )
    result['topartists']['artist']
  end

  def user_playcount(username)
    user_info(username)['playcount'].to_i
  end

  def user_url(username)
    user_info(username)['url']
  end

  def artist_top_albums(artist, number = 1000)
    get(
      'method=artist.gettopalbums' + \
      '&artist=' + artist + \
      '&limit=' + number.to_s
    )
  end

  def artist_top_tracks(artist, number = 1000)
    get(
      'method=artist.gettoptracks' + \
      '&artist=' + artist + \
      '&limit=' + number.to_s
    )
  end

  def album_info(artist, album)
    get(
      'method=album.getinfo' + \
      '&artist=' + artist + \
      '&album=' + album
    )
  end

  def track_info(artist, track)
    get(
      'method=track.getinfo' + \
      '&artist=' + artist + \
      '&track=' + track
    )
  end

  private 

  def get(query)
    self.class.get(
      '?api_key=' + ENV['LASTFM_KEY'] + \
      '&format=json&' + query
    )
  end
end

connection = LastFM.new

binding.pry