require 'rails_helper'

RSpec.describe User do

  let!(:user) { FactoryGirl.create(:user, uid: 'gopigasus') }

  describe '#from_omniauth:' do
    it 'returns user if user already exists' do
      existing_user_hash = mock_auth_hash
      result = User.from_omniauth(existing_user_hash)
      expect(result).to be_a(User)
      expect(result.persisted?).to be(true)
    end

    it 'creates and returns persisted if user does not exist' do
      non_existing_user_hash = OmniAuth::AuthHash.new({
        "provider"=>"lastfm",
        "uid"=>"idonotexist",
        "info"=>{"name"=>nil, "image"=>"fake-image.png"},
        "extra"=>{"raw_info"=>{"playcount"=>"666"}}
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
      expect(user.avatar).to match(/^(http:\/\/).*(.png)$/)
    end
  end

  describe '#playcount' do
    it 'returns user playcount' do
      expect(user.avatar).to eq(46500)
    end
  end

  describe '#top_artists(period, n)' do
    it 'returns top n artists' do
      top10 = user.top_artists('overall', 10)
      top15 = user.top_artists('overall', 15)

      expect(top10).to be_a Array
      expect(top10.length).to eq(10)
      expect(top10.sample).to be_a Artist

      expect(top15).to be_a Array
      expect(top15.length).to eq(15)
      expect(top15.sample).to be_a Artist
    end

    it 'returns top artists for different periods' do
      periods = ['7day', '1month', '3month', '6month', '12month', 'overall']
      periods.each do |period|
        top5 = user.top_artists(period, 5)
        expect(top5).to be_a Array
        expect(top5.length).to eq(5)
      end
    end
  end

  describe '#update_info' do
    before :each do
      user.username = 'n0body'
      user.image = 'another_image.jpg'
      user.playcount = 2
      user.save
      user.update_info
    end

    it 'updates username' do
      expect(user.username).to eq('gopigasus')
    end

    it 'updates user image' do
      expect(user.image).to eq('http://img2-ak.lst.fm/i/u/300x300/3986da997db38257ff069000e7467d32.png')
    end

    it 'updates user playcount' do
      expect(user.playcount).to be_greater_than('46500') 
    end
  end
end
