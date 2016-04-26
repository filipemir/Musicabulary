def artist_loader(name)
  artist = Artist.where(name: name).first_or_create
  artist.update_info
  artist.total_words ||= 0

  artist.total_words = artist.songs.inject(0) do |a, song|
    a + song.total_words
  end
  artist.save

  get_records_hash = {
      sort: 'year',
      sort_order: 'asc',
      page: 1,
      per_page: 100,
      token:  ENV['DISCOGS_TOKEN']
  }

  records = discogs_query(
    'artists/' + artist.discogs_id.to_s +  '/releases',
    get_records_hash
  )

  records['releases'].each do |release| if records
    break if artist.total_words >= WORD_SAMPLE_SIZE
    if release['type'] == 'master' && release['role'] == 'Main'
      record_id = release['id']
      record = Record.where(
          artist: artist,
          title: release['title'],
          year: release['year']
        ).first_or_create
      record.discogs_id ||= record_id

      tracks = discogs_query('/masters/' + record_id.to_s)['tracklist']

      tracks.each do |track|
        song = Song.where(title: track['title'], record: record).first_or_create do |s|
          position = track['position'].strip
          position = position.rjust(3, '0') if Integer(position) rescue false
          s.position = position
        end

        if song.lyrics.nil?
          filepath = "./db/lyrics_archive/#{clean(artist.name)}-#{clean(song.title)}.csv"
          if File.file?(filepath)
            puts filepath
            song.lyrics = CSV.read(filepath).flatten[0]
            song.save
          end
          if song.lyrics.nil? || song.lyrics == ''
            song.lyrics = scrape_song_lyrics(artist.name, song.title)
            unless song.lyrics.nil?
              CSV.open(filepath, 'wb') { |file| file << [song.lyrics] }
            end
          end
          song.save
          artist.total_words += song.lyrics.split.length unless song.lyrics.nil?
          artist.wordiness
          artist.save
        end
      end
    end
  end
end

def lastfm_query(params)
  params = params.merge(
    api_key: ENV['LASTFM_KEY'],
    format: 'json'
  )
  response = HTTParty.get('http://ws.audioscrobbler.com/2.0/', query: params)
  response.keys.include?('error') ? false : response
rescue
  false
end

def discogs_query(path, params = {})
  params = params.merge(token: ENV['DISCOGS_TOKEN'])
  response = HTTParty.get('https://api.discogs.com/' + path, query: params)
  success = response.empty? || response['message'] != 'The requested resource was not found.'
  success ? response : false
rescue
  false
end

def update_lyrics
  result = read_attribute(:lyrics)
  if result.nil?
    result = scrape_song_lyrics
    write_attribute(:lyrics, result)
    save
  end
  increment_artist_total_words
end

def increment_artist_total_words
  unless lyrics.nil?
    word_count = lyrics.split.length
    artist.total_words = 0 if artist_total_words == nil
    artist_total_words += word_count
    artist.save
  end
end

def clean(attribute)
  string = attribute.dup
  string.strip!
  string.delete!("'")
  string.gsub!("&", 'and')
  string.gsub!(/[^0-9A-Za-z\-]/, '-')
  string.squeeze!('-')
  string.chomp!('-')
  string.gsub!(/^\-/, '')
  string
end

def scrape_song_lyrics(artist, title)
  url = "http://genius.com/#{clean(artist)}-#{clean(title)}-lyrics".downcase
  puts url
  response_html = HTTParty.get(url)
  response = Nokogiri::HTML(response_html)
  lines = response.css('lyrics > p')
  result = ''
  lines.each { |line| result += ' ' + line }
  result.gsub!(/\[.*\]|\(x\d\)/, '')
  result.squeeze!("\n")
  result.strip
  result == '' ? nil : result
rescue
  nil
end

artists = lastfm_query(
  method: 'user.gettopartists',
  user: 'gopigasus',
  period: '365days',
  limit: 100
)

artists = artists['topartists']['artist']
artists.each_with_index do |artist, i|
  artist_loader(artist['name'])
end

# # artist_loader('Bob Dylan')
# # artist_loader('Wilco')
# # artist_loader('Bahamas')
# # artist_loader('Shovels & Rope')
# # artist_loader('Josh Ritter')
# # artist_loader('The Decemberists')
# # artist_loader('Justin Townes Earle')
# # artist_loader('Aesop Rock')