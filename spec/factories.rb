FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    provider 'lastfm'
    password 'password'
    image "sample-image.png"
    sequence(:playcount) { |n| "#{n}" }
  end

  factory :favorite do
    user
    artist
    timeframe FAVORITES_TIMEFRAME
    sequence(:rank) { |n| n }
    playcount 666
  end

  factory :artist do
    sequence(:name) { |n| "Artist Number #{n}" }
  end

  factory :record do
    sequence(:title) { |n| "Record Title #{n}" }
    year 1994
    artist
  end

  factory :song do
    sequence(:title) { |n| "Song Title #{n}" }
    record
  end
end
