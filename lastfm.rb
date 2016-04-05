require 'httparty'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load

class User
  include HTTParty

  attr_reader :user

  base_uri 'http://ws.audioscrobbler.com/2.0/'

  def initialize(user)
    @username = user
  end

  def user_info
    get('method=user.getinfo')
  end

  def top_artists(timeframe)
    get('method=user.gettopartists' +\
        '&period=' + timeframe)
  end

  def top_artists(timeframe)
    http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&user=gopigasus&api_key=149d191bd608cad5f6422c0d38799077&format=json&period=7day
  end

  private 

  def get(query)
    self.class.get('?api_key=' + ENV['LASTFM_KEY'] + \
                   '&format=json&user=' + username + \
                   '&' + query)
  end


end

user = LastFM.new('gopigasus')

binding.pry

# http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=rj&api_key=149d191bd608cad5f6422c0d38799077&format=json
# http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=gopigasus&api_key=149d191bd608cad5f6422c0d38799077&format=json

# http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=gopigasus&api_key=149d191bd608cad5f6422c0d38799077&format=JSON