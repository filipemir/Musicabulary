require_relative 'modules/genius'

class Song < ActiveRecord::Base
  include Genius

  belongs_to :record
  has_one :artist, through: :record

  validates :title, uniqueness: { scope: :record }

  def update_lyrics
    result = read_attribute(:lyrics)
    if result.nil?
      result = scrape_song_lyrics
      write_attribute(:lyrics, result)
    end
    increment_artist_total_words
  end

  def total_words
    lyrics.nil? ? 0 : lyrics.split.length
  end

  private

  def increment_artist_total_words
    unless lyrics.nil?
      artist.total_words += total_words
      artist.save
    end
  end
end
