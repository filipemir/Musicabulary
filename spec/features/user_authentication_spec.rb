require 'rails_helper'

feature 'User authentication:' do

  before :each do
    visit unauthenticated_root_path
    click_on 'Sign In'
  end

  scenario 'User can login with lastfm' do
    expect(page).to have_content('Hello')
  end

  scenario 'User can log out after logging in' do
    click_on 'Sign Out'
    expect(page).to have_content('Goodbye')
    expect(page).to have_button('Sign In')
    expect(page).to_not have_content('Sign Out')
  end

  scenario 'User sees top artists upon logging in' do
    expect(page).to have_current_path favorites_path
  end

end