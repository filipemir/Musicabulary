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
    it "updates records" do
      artist.update_records
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

    it "updates records" do
      artist.update
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

  describe '#words' do
    it 'returns array of words in lyrics by artist in db' do
      record = FactoryGirl.create(:record, artist: artist)
      FactoryGirl.create(:song, record: record, lyrics: 'Here are four words')
      expect(artist.words.sample).to be_a String
      expect(artist.words.length).to eq(4)
    end

    it 'returns empty array if no lyrics are in db' do
      expect(artist.words).to eq([])
    end

    it 'returns words in order of recording' do
      record1 = FactoryGirl.create(:record, artist: artist, year: 2016)
      record2 = FactoryGirl.create(:record, artist: artist, year: 1997)
      record3 = FactoryGirl.create(:record, artist: artist, year: 1998)
      FactoryGirl.create(:song, record: record1, lyrics: 'across the bluebird sky')
      FactoryGirl.create(:song, record: record2, lyrics: 'chuckled prayer')
      FactoryGirl.create(:song, record: record3, lyrics: 'tangled talk')
      expected_result = %w(chuckled prayer tangled talk across the bluebird sky)
      expect(artist.words).to eq(expected_result)
    end
  end

  describe '#first_words' do
    it 'returns first n words, up to WORD_SAMPLE_SIZE' do
      artist.update
      expect(artist.first_words.sample).to be_a String
      expect(artist.first_words.length).to eq(WORD_SAMPLE_SIZE)
    end

    it 'returns false if no lyrics are in db' do
      expect(artist.first_words).to eq(false)
    end

    it 'returns false if lyrics in db do not add up to WORD_SAMPLE_SIZE' do
      record = FactoryGirl.create(:record, artist: artist)
      FactoryGirl.create(:song, record: record, lyrics: 'Here are four words')
      expect(artist.first_words).to eq(false)
    end
  end

  describe '#wordiness' do
    it 'returns ratio of number unique first words to WORD_SAMPLE_SIZE' do
      artist.update
      expect(artist.wordiness).to be_between(0, 1).exclusive
    end

    it 'returns false if no lyrics are in db' do
      expect(artist.wordiness).to be_nil
    end

    it 'returns false if lyrics in db do not add up to WORD_SAMPLE_SIZE' do
      record = FactoryGirl.create(:record, artist: artist)
      FactoryGirl.create(:song, record: record, lyrics: 'Here are five more words')
      expect(artist.wordiness).to be_nil
    end
  end

end
