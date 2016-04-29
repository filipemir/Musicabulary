class Artist < ActiveRecord::Base
  include Discogs

  has_many :users, through: :favorites
  has_many :records
  has_many :songs, through: :records

  validates :name, presence: true
  validates :name, allow_nil: true, uniqueness: { case_sensitive: false }

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
    total_words < WORD_SAMPLE_SIZE ? nil : words[0..WORD_SAMPLE_SIZE - 1]
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
      self.records_loaded = true
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
end
