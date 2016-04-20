require 'rails_helper'

RSpec.describe User do

  let!(:user) { FactoryGirl.create(:user, username: 'gopigasus') }

  describe '#from_omniauth:' do
    it 'returns user if user already exists' do
      existing_user_hash = mock_auth_hash
      result = User.from_omniauth(existing_user_hash)
      expect(result).to be_a(User)
      expect(result.persisted?).to be(true)
    end

    it 'creates and returns persisted user if user did not previously exist' do
      non_existing_user_hash = OmniAuth::AuthHash.new({
        "provider"=>"lastfm",
        "uid"=>"i_d0_n0t_exist_1931",
        "info"=>{"name"=>nil, "image"=>"fake-image.png"},
        "extra"=>{"raw_info"=>{"playcount"=>"665"}}
      })
      result = User.from_omniauth(non_existing_user_hash)
      expect(result).to be_a(User)
      expect(result.persisted?).to be(true)
    end
  end

  describe '#username' do
    it 'returns username' do
      expect(user.username).to eq('gopigasus')
    end
  end

  describe '#image' do
    it 'returns url of user profile picture' do
      expect(user.avatar).to eq('http://img2-ak.lst.fm/i/u/300x300/3986da997db38257ff069000e7467d32.png')
    end
  end

  describe '#playcount' do
    it 'returns user playcount' do
      expect(user.playcount).to be_a Integer
      expect(user.playcount).to be > 0
    end
  end

  describe '#top_artists' do
    before :each do
      10.times { FactoryGirl.create(:favorite, user: user) }
    end

    it 'returns top 10 artists in user favorites' do
      expect(user.top_artists.length).to eq(10)
      expect(user.top_artists.sample).to be_a Artist
    end

    it 'returns artists sorted by rank in ascending order' do
      user.top_artists.each_with_index do |artist, i|
        favorite = Favorite.find_by(user: user, artist: artist, timeframe: 'overall')
        expect(favorite.rank).to eq(i + 1)
      end
    end
  end

  describe '#update' do
    before :each do
      user.username = 'n0body'
      user.image = 'another_image.jpg'
      user.playcount = 2
      user.artists.destroy_all
      user.favorites.destroy_all
      user.save
      binding.pry
      user.update
    end

    it 'updates username' do
      expect(user.username).to eq('gopigasus')
    end

    it 'updates user image' do
      expect(user.image).to eq('http://img2-ak.lst.fm/i/u/300x300/3986da997db38257ff069000e7467d32.png')
    end

    it 'updates user playcount' do
      expect(user.playcount).to be >= 46500
    end

    it 'updates user top artists' do
      expect(user.top_artists.length).to eq(10)
      expect(user.top_artists.sample).to be_a Artist
      user.top_artists.each_with_index do |artist, i|
        favorite = Favorite.find_by(user: user, artist: artist, timeframe: 'overall')
        expect(favorite.rank).to eq(i + 1)
      end
    end
  end
end
