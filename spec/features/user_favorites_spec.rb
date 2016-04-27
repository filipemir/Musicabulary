# require 'rails_helper'

# VCR.turned_off do

#   feature 'User favorites:', js: true do
#     before :each do
#       binding.pry
#       visit unauthenticated_root_path
#       click_on 'Sign In'
#       click_on 'Sign in with Lastfm'
#       visit favorites_path
#       sleep(200 * FAVORITES_NUM / 1_000) 
#     end

#     scenario 'User sees a bubble for each favorite artist' do
#       expect(page).to have_css('.artist-bubble', count: FAVORITES_NUM)
#     end

#     scenario 'User sees bubbles ordered by wordiness (less wordy to the left)' do
#       artists = User.first.top_artists
#       artists.select! { |artist| !artist.wordiness.nil? }
#       artists.sort { |a, b| a.wordiness <=> b.wordiness }
#       positions = artists.map do |artist|
#         element_position_by_id("bubble-#{artist.id}")
#       end
#       i = 1;
#       (positions.length - 1).times do
#         expect(positions[i - 1][0]).to be <= positions[i][0]
#         i += 1
#       end
#     end

#     # scenario 'User hovers over a bubble' do
#     #   it "to see the artist's name" do
#     #   end

#     #   it "to see the artist's wordiness (if available)" do
#     #   end 

#     #   it "to see a message if artist doesn't have enough words" do
#     #   end

#     #   it "to see a placeholder if artist is still loading" do
#     #   end
#     # end
#   end

# end