class Song < ActiveRecord::Base
  belongs_to :record
  has_one :artist, through: :record

  def update
    self.lyrics ||= scrape_song_lyrics
    save
  end

  def word_count
    lyrics ? lyrics.split.length : 0
  end

  private

  def clean(attribute)
    string = attribute
    string.strip!
    string.gsub!("'", '')
    string.gsub!(/[^0-9A-Za-z\-]/, '-')
    string.squeeze!('-')
    string.chomp!('-')
    string.gsub!(/^\-/, '')
    string
  end

  def scrape_song_lyrics
    begin
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
end