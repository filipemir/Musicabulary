require 'rails_helper'

RSpec.describe Song do

  let(:artist)    { FactoryGirl.create(:artist, name: 'Aesop Rock') }
  let(:record)    { FactoryGirl.create(:record, artist: artist) }
  let(:song)      { FactoryGirl.create(:song, title: 'Big Bang', record: record) }
  let(:fake_song) { FactoryGirl.create(:song, title: 'asdjssdfdssd') }
  let(:url)       { "http://genius.com/aesop-rock-big-bang-lyrics" }

  describe '#update' do
    it "updates song lyrics if lyrics weren't previously loaded" do
      song.update
      expect(WebMock).to have_requested(:get, url).once
      expect(song.lyrics).to include("man I really can't afford the oxen")
    end

    it "leaves lyrics unchanged if lyrics already in db" do
      3.times { song.update }
      expect(WebMock).to have_requested(:get, url).once
      expect(song.lyrics).to include("man I really can't afford the oxen")
    end

    it "leaves lyrics as nil if no lyrics found" do
      fake_song.update
      expect(fake_song.lyrics).to be_nil
    end
  end

  describe '#word_count' do
    it "returns 0 if song has no lyrics or lyrics haven't been loaded" do
      expect(song.word_count).to eq(0)
    end

    it "returns count of words if lyrics loaded" do
      song.update
      expect(song.word_count).to eq(1091)
    end

    it "returns 0 if no lyrics found" do
      fake_song.update
      expect(fake_song.word_count).to eq(0)
    end
  end

  describe '#artist' do
    it "returns song's artist" do
      expect(song.artist).to be_a Artist
      expect(song.artist.name).to eq('Aesop Rock')
    end
  end

  describe '#record' do
    it "returns song's record" do
      expect(song.record).to be_a Record
    end
  end

end
