class Artist < ActiveRecord::Base
  has_many :users, through: :favorites
  has_many :records
  has_many :songs, through: :records

  validates :name, presence: true
  validates :name, allow_nil: true, uniqueness: { case_sensitive: false }

  include HTTParty
  base_uri 'https://api.discogs.com/'

  attr_writer :discogs_id

  def total_words
    words.length
  end

  def words
    reload
    result = []
    songs_sorted.each do |song|
      next if song.lyrics.nil?
      result += song.lyrics.split
    end
    result
  end

  def first_words
    words.length >= WORD_SAMPLE_SIZE ? words[0..WORD_SAMPLE_SIZE - 1] : false
  end

  def update_wordiness
    if first_words
      self.wordiness = first_words.uniq.length
      save
    end
  end

  def update
    discogs_id
    update_records if total_words < WORD_SAMPLE_SIZE
    update_wordiness
  end

  def discogs_id
    result = read_attribute(:discogs_id)
    if result.nil?
      id = get_discogs_id
      write_attribute(:discogs_id, id)
      save
      return id
    end
    result
  end

  def update_records
    page = get_artist_records_page(1)
    if page
      page['releases'].each do |release|
        break if total_words >= WORD_SAMPLE_SIZE
        if release['type'] == 'master' && release['role'] == 'Main'
          record = Record.where(
            artist: self,
            title: release['title'],
            year: release['year']
          ).first_or_create
          record.discogs_id ||= release['id']
          record.update
        end
      end
    end
  end

  def songs_sorted
    songs.sort do |a, b|
      a_vals = [a.record.year, a.record.title, a.position]
      b_vals = [b.record.year, b.record.title, b.position]
      a_vals <=> b_vals
    end
  end

  private

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
