class Artist < ActiveRecord::Base
  has_many :users, through: :favorites
end