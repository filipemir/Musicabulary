FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    provider 'lastfm'
    password 'password'
    image "sample-image.png"
    sequence(:playcount) { |n| "#{n}" }
  end

  factory :artist do
    sequence(:name) { |n| "Artist Number #{n}"}
  end

  factory :favorite do
    user
    artist
    timeframe 'overall'
    sequence(:rank) { |n| n }
    playcount 666
  end
end
