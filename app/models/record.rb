class Record < ActiveRecord::Base
  belongs_to :artist
  has_many :songs

  include HTTParty
  base_uri 'https://api.discogs.com/'

  def update
    tracks = get_songs
    if tracks
      tracks.each do |track|
        Song.where(title: track['title'], record: self).first_or_create do |s|
          position = track['position'].strip
          if (Integer(position) rescue false)
            position = position.rjust(3, padstr='0')
          end
          s.position = position
          s.update
        end
      end
    end
    save
    reload
  end

  private

  def get_songs
    result = []
    record = discogs_query('/masters/' + discogs_id.to_s)
    record ? record['tracklist'] : false
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