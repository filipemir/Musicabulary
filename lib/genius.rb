module Genius
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
    puts 'Genius scraping failed'
    nil
  end
end