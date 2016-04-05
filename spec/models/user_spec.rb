require_relative '../spec_helper'

RSpec.describe User do

  let!(:user) { User.new('gopigasus') }
  let!(:fake_user) { User.new('idonotexist')}

  describe '#username' do
    it 'returns username' do
      expect(user.username).to eq('gopigasus')
    end
  end

  describe '#avatar' do
    it 'returns url of users avatar picture' do
      expect(user.avatar).to match(/^(http:\/\/).*(.png)$/)
    end

    it 'returns default user pic if no user picture is available' do
      expect(fake_user.avatar).to eq('default.jpg')
    end
  end

  describe '#url' do
    it 'returns url of users profile' do
      expect(user.url).to eq("http://www.last.fm/user/gopigasus")
    end
  end

  describe '#playcount' do
    it 'returns number of tracks played by user' do
      expect(user.url).to be_a String
    end
  end

  describe '#top_artists(period, n)' do
    it 'returns top n artists' do
      top10 = user.top_artists('overall', 10)
      top15 = user.top_artists('overall', 15)
      expect(top10).to be_a Array
      expect(top10.length).to eq(10)
      expect(top15).to be_a Array
      expect(top15.length).to eq(15)
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
  
end