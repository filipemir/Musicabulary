require_relative 'lastfm'
require_relative 'discogs'
require_relative 'genius_scraper'
require_relative 'models'



user = User.new('gopigasus')
user_top = user.top_artists

artists = []
user_top.each do |artist|
  name = artist['name']
  artists << Artist.new(name)
end

artist = artists[3]
artist.update_info

record = artist.records[2]
tracks = record.grab_tracks

lyrics = []

tracks.each do |track|
  lyrics << GeniusScraper.get_song_lyrics(track.artist, track.title)
end


binding.pry
