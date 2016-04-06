require 'httparty'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load

class User
  include HTTParty

  attr_reader :username

  base_uri 'http://ws.audioscrobbler.com/2.0/'

  def initialize(username)
    @username = username
  end

  def top_artists(timeframe, number)
    result = get(
      'method=user.gettopartists' + \
      '&period=' + timeframe + \
      '&limit=' + number.to_s
    )
    result['topartists']['artist']
  end

  def avatar
    images = user_info['image']
    image = images.select { |image| image['size'] == 'large' }
    image = image[0]['#text']
    ['', nil].include?(image) ? 'default.jpg' : image
  end

  def playcount
    user_info['playcount'].to_i
  end

  def url
    user_info['url']
  end

  private 

  def get(query)
    self.class.get(
      '?api_key=' + ENV['LASTFM_KEY'] + \
      '&format=json&user=' + username + \
      '&' + query
    )
  end

  def user_info
    get('method=user.getinfo')['user']
  end

end