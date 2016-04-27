require 'rails_helper'

RSpec.describe Artist do

  let(:artist) { FactoryGirl.create(:artist, name: 'Tom Waits') }
  let(:fake_artist) { FactoryGirl.create(:artist, name: 'kmsdkjfdfgx') }
  let(:taciturn_artist) { FactoryGirl.create(:artist, name: 'Russian Circles') }

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
      artist.update_records
      expect(artist.total_words).to be_a Integer
      expect(artist.total_words).to be >= WORD_SAMPLE_SIZE
    end
  end

  describe '#update_records' do
    it "updates records" do
      artist.update_records
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end

    it "changes the state of records_loaded to true" do
      artist.update_records
      expect(artist.records_loaded).to eq(true)
    end
  end

  describe '#update_info' do
    it "updates artist's discogs id" do
      expect(artist.read_attribute(:discogs_id)).to be_nil
      artist.update_info
      expect(artist.read_attribute(:discogs_id)).to eq(82294)
    end

    it "updates discogs image" do
      artist.update_info
      expect(artist.discogs_image).to be_a String
    end
  end

  describe '#update_records' do
    it "updates records" do
      artist.update_records
      expect(artist.records).to_not be([])
      expect(artist.records.sample).to be_a Record
    end
  end

  describe '#songs_sorted' do
    before { artist.update_records }

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

  describe '#words' do
    it 'returns array of words in lyrics by artist in db' do
      expect(artist.words.sample).to be_a String
      expect(artist.words.length).to be >= WORD_SAMPLE_SIZE
    end

    it 'returns empty array if no lyrics are in db' do
      expect(fake_artist.words).to eq([])
    end

    it 'returns words sorted by release year in ascending order' do
      words = artist.words
      songs = artist.songs_sorted
      expect(songs[0].lyrics).to include words[0]
      expect(songs[-1].lyrics).to include words[-1]
    end
  end

  describe '#first_words' do
    it 'returns first n words, up to WORD_SAMPLE_SIZE' do
      expect(artist.first_words.sample).to be_a String
      expect(artist.first_words.length).to eq(WORD_SAMPLE_SIZE)
    end

    it 'returns nil if no lyrics are in db' do
      expect(fake_artist.first_words).to eq(nil)
    end

    it 'returns nil if lyrics in db do not add up to WORD_SAMPLE_SIZE' do
      expect(taciturn_artist.first_words).to eq(nil)
    end
  end

  describe '#wordiness' do
    it 'returns number of unique words within first words' do
      expect(artist.wordiness).to be_between(0, WORD_SAMPLE_SIZE).exclusive
    end

    it 'returns nil if no lyrics are in db' do
      expect(fake_artist.wordiness).to eq(nil)
    end

    it 'returns nil if lyrics in db do not add up to WORD_SAMPLE_SIZE' do
      expect(taciturn_artist.wordiness).to eq(nil)
    end
  end

end
