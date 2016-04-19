require 'rails_helper'

RSpec.describe Artist do
  before :each do
    artist = FactoryGirl.create(:artist, name: 'Aesop Rock')
  end

  describe '#name' do
    it "returns artist's names" do
      expect(artist.name).to eq('Aesop Rock')
    end
  end

  describe '#id' do
    it "returns artist's lastfm id" do
      expect(artist.id).to eq()
    end
  end

  describe '#records' do
    it "returns array with artist's records" do
      expect(artist.records).to be_a Array
      expect(artist.records.length).to eq()
      expect(artist.records.sample).to be_a Record
    end
  end

  describe '#songs' do
    it "returns array with artist's songs" do
      expect(artist.records).to be_a Array
      expect(artist.records.length).to eq()
      expect(artist.records.sample).to be_a Song
    end
  end
end