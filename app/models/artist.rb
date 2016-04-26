class Artist < ActiveRecord::Base
  has_many :users, through: :favorites
  has_many :records
  has_many :songs, through: :records

  validates :name, presence: true
  validates :name, allow_nil: true, uniqueness: { case_sensitive: false }

  include HTTParty
  base_uri 'https://api.discogs.com/'

  attr_writer :discogs_id

  def words
    reload
    result = []
    update_records unless records_loaded
    songs_sorted.each do |song|
      next if song.lyrics.nil?
      result += song.lyrics.split
    end
    result
  end

  def first_words
    update_records unless records_loaded
    total_words < WORD_SAMPLE_SIZE ? false : words[0..WORD_SAMPLE_SIZE - 1]
  end

  def wordiness
    result = read_attribute(:wordiness)
    if result.nil?
      result = first_words
      result = result.uniq.length if result
      write_attribute(:wordiness, result)
      save
    end
    result
  end

  def songs_sorted
    songs.sort do |a, b|
      a_vals = [a.record.year, a.record.title, a.position]
      b_vals = [b.record.year, b.record.title, b.position]
      a_vals <=> b_vals
    end
  end

  def update_info
    discogs_id
    discogs_image
  end

  def discogs_id
    result = read_attribute(:discogs_id)
    if result.nil?
      result = get_discogs_id
      write_attribute(:discogs_id, result)
      save
    end
    result
  end

  def discogs_image
    result = read_attribute(:discogs_image)
    if result.nil?
      result = get_discogs_image
      write_attribute(:discogs_image, result)
      save
    end
    result
  end

  def update_records
    page = get_artist_records_page(1)
    if page
      page['releases'].each do |release|
        break if total_words >= WORD_SAMPLE_SIZE
        update_record(
          release['title'],
          release['year'],
          release['id'],
          release['type'],
          release['role']
        )
      end
      records_loaded = true
      save
    end
  end

  private

  def update_record(title, year, discogs_id, release_type, role)
    if release_type == 'master' && role == 'Main'
      record = Record.where(artist: self, title: title, year: year).first_or_create
      record.discogs_id ||= discogs_id
      record.update_songs
      reload
    end
  end

  def get_discogs_id
    response = discogs_query('/database/search', q: name)
    if response
      response['results'].each do |result|
        type = result['type']
        id = result ['id']
        return id if type == 'artist'
      end
    end
    nil
  end

  def get_discogs_image
    response = discogs_query('/artists/' + discogs_id.to_s)
    if response
      images = response['images']
      return images.first['uri'] if images
    end
    nil
  end

  def get_artist_records_page(page_num)
    discogs_query(
      '/artists/' + discogs_id.to_s + '/releases',
      sort: 'year',
      sort_order: 'asc',
      page: page_num,
      per_page: 100
    )
  rescue
    false
  end

  def discogs_query(path, params = {})
    params = params.merge(token: ENV['DISCOGS_TOKEN'])
    response = self.class.get(path, query: params)
    success = response.empty? || response['message'] != 'The requested resource was not found.'
    success ? response : false
  rescue
    false
  end
end
