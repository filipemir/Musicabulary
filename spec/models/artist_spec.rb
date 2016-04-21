require 'rails_helper'

RSpec.describe Artist do

  let(:artist) { FactoryGirl.create(:artist, name: 'Aesop Rock') }

  describe '#name' do
    it "returns artist's names" do
      expect(artist.name).to eq('Aesop Rock')
    end
  end

  describe '#discogs_id' do
    it "returns artist's discogs id" do
      expect(artist.discogs_id).to eq(28104)
    end
  end

  describe '#songs_sorted' do
    it "returns artist's songs" do
      expect(artist.songs_sorted.length).to eq(1)
      expect(artist.songs_sorted.sample).to be_a Record
    end

    it "returns songs sorted by release year in ascending order" do
      songs = artist.songs
      (1..songs.length).each do |i|
        expect(songs[i].year).to be >= songs[i - 1].year
      end
    end
  end

end
