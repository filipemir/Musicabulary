require 'rails_helper'

feature 'User authentication:' do
  scenario 'First-time user logs in with last.fm' do
    visit root_path
    click 'Login with last.fm'
    expect(page).to have_content('Your top artists')
    expect(page).to have_css('artist', count: 10)
  end
end