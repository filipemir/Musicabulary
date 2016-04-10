require 'httparty'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load

module LastFM
  def self.included(receiving_class)
    receiving_class.send :include, HTTParty
    receiving_class.send :base_uri, 'http://ws.audioscrobbler.com/2.0/'
  end

  def lastfm_query(params)
    params = params.merge(
      api_key: ENV['LASTFM_KEY'], 
      format: 'json'
    )
    self.class.get('', query: params)
  end
end

class User
  include LastFM

  attr_reader :username

  def initialize(username)
    @username = username
  end

  def top_artists(timeframe = "overall", number = 50)
    result = lastfm_query(
      method: 'user.gettopartists',
      user: username,
      period: timeframe,
      limit: number.to_s
    )
    result['topartists']['artist']
  end
end

class Artist
  include LastFM

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def top_records
    top('albums')
  end

  def top_tracks
    top('tracks')
  end

  private

  def top(item, number = 1000)
    lastfm_query(
      method: 'artist.gettop' + item,
      artist: name,
      limit: number.to_s
    )
  end
end


# user = User.new('gopigasus')
# artist = Artist.new('Laura Stevenson')


binding.pry