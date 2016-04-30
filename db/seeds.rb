def create_song(artist, record, song_info)
  song = Song.where(title: song_info['title'], record: record).first_or_create do |s|
    position = song_info['position'].strip
    position = position.rjust(3, '0') if Integer(position) rescue false
    s.position = position
  end
  if song.lyrics.nil?
    clean_artist = song.clean(artist.name)
    clean_title = song.clean(song.title)
    filepath = "./db/lyrics_archive/#{clean_artist}-#{clean_title}.csv"

    if Rails.env == "development" && File.file?(filepath)
      puts filepath
      song.lyrics = CSV.read(filepath).flatten[0]
      song.save
    end

    if song.lyrics.nil? || song.lyrics == ''
      song.lyrics = song.scrape_song_lyrics
      unless song.lyrics.nil? && Rails.env == "development"
        CSV.open(filepath, 'wb') { |file| file << [song.lyrics] }
      end
    end

    song.save
    artist.total_words += song.lyrics.split.length unless song.lyrics.nil?
    artist.save
  end
end

def create_records(artist, records_info)
  records = records_info['releases']
  records.each do |release|
    break if artist.total_words >= WORD_SAMPLE_SIZE
    if release['type'] == 'master' && release['role'] == 'Main'
      record_id = release['id']
      record = Record.where(
          artist: artist,
          title: release['title'],
          year: release['year']
        ).first_or_create
      record.discogs_id ||= record_id
      tracks = record.get_record_songs
      tracks.each { |track| create_song(artist, record, track) }
    end
  end
end

def create_artists(artists_info, user)
  artists_info.each_with_index do |artist, i|
    artist = Artist.where(name: artist['name']).first_or_create
    if user.username == 'last.fm'
      fave = Favorite.where(
        user: user,
        artist: artist
      ).first_or_create
      fave.rank = (i + 1).to_s
      fave.save
    end
    artist.update_info
    records = artist.get_artist_records_page(1)
    create_records(artist, records) if records
    artist.wordiness
    artist.save
  end
end

lastfm = User.where(username: 'last.fm').first_or_create
overall_top_artists = lastfm.get_lastfm_top_artists(100, 1)
create_artists(overall_top_artists, lastfm)

seed_user = User.where(username: 'gopigasus').first_or_create
seed_user_artists = seed_user.get_top_artists("12month", 100)
create_artists(seed_user_artists, seed_user)


