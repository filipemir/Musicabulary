require 'rails_helper'

RSpec.describe Artist do

  let(:artist) { FactoryGirl.create(:artist, name: 'Tom Waits') }

  describe '#discogs_id' do
    it "returns artist's discogs id" do
      expect(artist.discogs_id).to eq(82294)
    end

    it "updates artist's discogs id" do
      expect(artist.read_attribute(:discogs_id)).to be_nil
      artist.discogs_id
      expect(artist.read_attribute(:discogs_id)).to eq(82294)
    end
  end

  describe '#total_words' do
    it 'returns zero if no lyrics are stored in db' do
      expect(artist.total_words).to eq(0)
    end

    it 'returns total number of words in lyrics stored in db' do
      artist.update
      expect(artist.total_words).to be_a Integer
      expect(artist.total_words).to be > WORD_SAMPLE_SIZE
    end
  end

  describe '#update_records' do
    it "updates records if records weren't previously loaded" do
      expect { artist.update_records }.to output.to_stdout
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end

    it "leaves records unchanged if records already in db" do
      artist.update_records
      expect { artist.update_records }.to_not output.to_stdout
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end
  end

  describe '#update' do
    it "updates artist's discogs id" do
      expect(artist.read_attribute(:discogs_id)).to be_nil
      artist.update
      expect(artist.read_attribute(:discogs_id)).to eq(82294)
    end

    it "updates records if records weren't previously loaded" do
      expect { artist.update }.to output.to_stdout
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end

    it "leaves records unchanged if records already in db" do
      artist.update
      expect { artist.update }.to_not output.to_stdout
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end
  end

  describe '#songs_sorted' do
    before { artist.update }

    it "returns artist's songs" do
      expect(artist.songs_sorted.length).to eq(artist.songs.length)
      expect(artist.songs_sorted.sample).to be_a Song
    end

    it "returns songs sorted by release year in ascending order" do
      songs = artist.songs_sorted
      (1..songs.length - 1).each do |i|
        expect(songs[i - 1].record.year).to be <= songs[i].record.year
      end
    end

    it "sorts songs by record title within the same year" do
      songs = artist.songs_sorted.select { |song| song.record.year == 1973 }
      (1..songs.length - 1).each do |i|
        expect(songs[i - 1].record.title <=> songs[i].record.title).to be <= 0
      end
    end

    it "sorts songs by position within the same record" do
      record = artist.records.first
      songs = artist.songs_sorted.select { |song| song.record_id == record.id }
      (1..songs.length - 1).each do |i|
        expect(songs[i - 1].position <=> songs[i].position).to be <= 0
      end
    end
  end

end
