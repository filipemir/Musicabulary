require_relative 'lastfm'
require_relative 'discogs'
require_relative 'genius'
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

track = tracks[2]

genius = Genius.new
search_hits = genius.search(track.artist + ' ' + track.title + ' ' + track.record)

track_id = search_hits['response']['hits'].each do |hit|
  type = hit['type'].strip
  title = hit['result']['title'].strip
  hit_artist = hit['result']['primary_artist']['name'].strip
  if hit_artist == artist.name.strip && type == 'song' && title == track.title.strip
    break hit['result']['id']
  else
    false
  end
end




binding.pry
