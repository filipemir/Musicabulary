require 'httparty'
require 'dotenv'
require 'nokogiri'
require 'pry'

response = HTTParty.get('http://www.azlyrics.com/lyrics/aesoprock/daylight.html')
parsed_response = Nokogiri::HTML(response)
lyrics = parsed_response.at(
  '//comment()[contains(., "Sorry about that.")]'
  ).parent.text


binding.pry