require 'httparty'
require 'dotenv'
require 'nokogiri'
require 'pry'

module GeniusScraper
  def get_song_lyrics(artist, song)
    [artist, song].each do |string|
      string.strip!
      string.gsub!(/[^0-9A-Za-z.\-]/, '-')
      string.squeeze!('-')
      string.chomp!('-')
      string.gsub!(/^\-/, '')
    end
    url = "http://genius.com/#{artist}-#{song}-lyrics"
    response = Nokogiri::HTML(HTTParty.get(url))
    lines = response.css('lyrics > p')

    result = ''
    lines.each do |line|
      result += ' ' + line
    end
    result.gsub(/\[.*\]|\(x\d\)/, '').strip
  end
end

include GeniusScraper


  # lyrics1 = GeniusScraper.get_song_lyrics('Aesop Rock', 'Daylight')
  # lyrics2 = GeniusScraper.get_song_lyrics('Converge', 'Locust Reign')
  # lyrics3 = GeniusScraper.get_song_lyrics('Bob Dylan', 'One of us must know (sooner or later)')

