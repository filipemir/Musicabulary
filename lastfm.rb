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