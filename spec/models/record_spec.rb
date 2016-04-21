require 'rails_helper'

RSpec.describe Record do

  let(:artist) { FactoryGirl.create(:artist, name: 'Hop Along') }
  let(:record) do
    FactoryGirl.create(
      :record, 
      artist: artist, 
      title: "Painted Shut",
      discogs_id: 824583
    ) 
  end
  
  before { record.update }

  describe '#update' do
    it "loads songs if songs were not previously loaded in db" do
      songs = record.songs
      expect(songs.length).to eq(10)
      expect(songs.sample).to be_a Song
    end

    it "leaves songs unchanged if they had already been previously loaded" do
      songs = record.songs
      mod_times = songs.map { |song| song.updated_at }
      record.update
      updated_songs = record.songs
      updated_mod_times = updated_songs.map { |song| song.updated_at }
      expect(updated_mod_times).to eq(mod_times)
    end

    it "adds any songs from record which were previously missing" do
      record.songs.where(title: 'Sister Cities').delete_all
      expect(record.songs.length).to eq(9)

      record.update
      search = record.songs.where(title: 'Sister Cities')
      expect(record.songs.length).to eq(10)
      expect(search.length).to eq(1)
    end
  end

end
