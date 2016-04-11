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
  include Discogs

  attr_reader :name, :id, :records

  def initialize(name)
    @name = name
    @id = nil
    @records = nil
  end

  def update_info
    @id ||= get_artist_id
    @records ||= get_records
  end

  def get_records
    result = []
    page = 1
    total_pages = 1
    while page <= total_pages do
      request = get_artist_records(page)
      total_pages = request['pagination']['pages']
      request['releases'].each do |record|
        record_info = {
          title: record['title'],
          year: record['year'],
          id: record['id'],
          type: record['type']
        }
        result << Record.new(record_info) if record['role'] == 'Main'
      end
      page += 1
    end
    result
  end
end

class Record
  include Discogs

  attr_reader :title, :year, :discogs_id, :discogs_record_type

  def initialize(info)
    @title = info[:title]
    @year = info[:year]
    @discogs_id = info[:id]
    @discogs_record_type = info[:type]
    @tracks = nil
  end

  def grab_tracks
    @tracks ||= get_record_tracks(
      type = discogs_record_type, 
      id = discogs_id,
      record = title
    )
  end
end

class Song
  attr_reader :title, :artist, :record

  def initialize(title, artist, record)
    @title = title
    @artist = artist
    @record = record
    @lyrics = nil
  end
end