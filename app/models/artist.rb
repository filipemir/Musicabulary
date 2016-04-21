class Artist < ActiveRecord::Base
  has_many :users, through: :favorites
  has_many :records
  has_many :songs, through: :records

  include HTTParty
  base_uri 'https://api.discogs.com/'

  attr_writer :discogs_id

  def update
    discogs_id
    update_records
  end

  def discogs_id
    result = read_attribute(:discogs_id)
    if result.nil?
      id = get_discogs_id
      write_attribute(:discogs_id, id)
      return id
    end
    result
  end

  def total_words
    reload
    songs.inject(0) do |sum, song|
      sum + song.word_count
    end
  end

  def update_records
    page = get_artist_records_page(1)
    if page
      page['releases'].each do |release|
        puts total_words
        break if total_words >= 3_500
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

  def update_record(title, year, release_id)
    Record.where(
      artist: self,
      title: release['title'],
      year: release['year']
    ).first_or_create

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

  # def get_artist_records
  #   i = 1
  #   result = []
  #   total_pages = nil
  #   begin
  #     page = get_artist_records_page(i)
  #     if page
  #       total_pages ||= page['pagination']['pages'].to_i
  #       page['releases'].each do |release|
  #         if release['type'] == 'master' && release['role'] == 'Main'
  #           result << release
  #         end
  #       end
  #       i += 1
  #     else
  #       break
  #     end
  #   end while i <= total_pages
  #   binding.pry
  # end

  def get_artist_records_page(page_num)
    begin
      discogs_query(
        '/artists/' + discogs_id.to_s + '/releases',
        sort: 'year',
        sort_order: 'asc',
        page: page_num,
        per_page: 100,

      )
    rescue
      false
    end
  end

  def discogs_query(path, params = {})
    begin
      params = params.merge(token: ENV['DISCOGS_TOKEN'])
      response = self.class.get(path, query: params)
      success = response.empty? || response['message'] != 'The requested resource was not found.'
      success ? response : false
    rescue
      false
    end
  end
end
