class Record < ActiveRecord::Base
  include Discogs

  belongs_to :artist
  has_many :songs

  def update_songs
    tracks = get_record_songs
    if tracks
      tracks.each do |track|
        Song.where(title: track['title'], record: self).first_or_create do |s|
          position = track['position'].strip
          position = position.rjust(3, '0') if Integer(position) rescue false
          s.position = position
          s.update_lyrics
        end
      end
    end
    reload
  end
end
