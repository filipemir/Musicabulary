FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| "user#{n}" }
    provider 'lastfm'
    password 'password'
    sequence(:image) { |n| "sample-image#{n}.png" }
    sequence(:playcount) { |n| "#{n}" }
  end
end
