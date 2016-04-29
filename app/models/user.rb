require_relative 'modules/lastfm'

class User < ActiveRecord::Base
  include LastFM

  devise :database_authenticatable, :rememberable, :trackable,
         :omniauthable, omniauth_providers: [:lastfm]

  has_many :favorites
  has_many :artists, through: :favorites


  def update_info
    user_info = get_user_info
    if user_info
      images = user_info['image']
      xl_image = images.select { |image| image['size'] == 'extralarge' }
      self.image = xl_image.first['#text']
      self.playcount = user_info['playcount'].to_i
      save
    else
      false
    end
  end

  def update_favorites(timeframe = FAVORITES_TIMEFRAME, number = FAVORITES_NUM)
    artists_info = get_top_artists(timeframe, number)
    if artists_info
      artists_info.each do |artist_info|
        artist = Artist.where(name: artist_info['name']).first_or_create do |a|
          a.lastfm_image = artist_info['image'][2]['#text']
          a.update_info
        end
        fave = Favorite.where(user: self, artist: artist, timeframe: timeframe).first_or_create
        fave.rank = artist_info['@attr']['rank'].to_i
        fave.playcount = artist_info['playcount']
        fave.save
      end
    else
      false
    end
  end

  def top_artists(timeframe = FAVORITES_TIMEFRAME, number = FAVORITES_NUM)
    faves = favorites.order(:rank)
    result = []
    faves.each do |fave|
      if fave.timeframe == timeframe && fave.rank <= number
        result << fave.artist
      end
    end
    result
  end

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, username: auth.uid).first_or_create do |u|
      u.password = Devise.friendly_token[0, 20]
      u.image = auth.info.image
      u.playcount = auth.extra.raw_info.playcount
    end
    user
  end
end