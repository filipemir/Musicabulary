class Song < ActiveRecord::Base
  belongs_to :record
  has_one :artist, through: :record

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
      artist.total_words += total_words
      artist.save
    end
  end

  def total_words
    lyrics.nil? ? 0 : lyrics.split.length
  end

  private

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

  def scrape_song_lyrics
    url = "http://genius.com/#{clean(artist.name)}-#{clean(title)}-lyrics".downcase
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
end
