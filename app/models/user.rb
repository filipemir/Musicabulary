class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:lastfm]

  has_many :favorites
  has_many :artists, through: :favorites

  include HTTParty
  base_uri 'http://ws.audioscrobbler.com/2.0/'

  def update
    update_info && update_favorites
  end

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

  def update_favorites(timeframe = FAVORITES_TIMEFRAME, number = 10)
    artists_info = get_top_artists(timeframe, number)
    if artists_info
      artists_info.each do |artist_info|
        artist = Artist.where(name: artist_info['name']).first_or_create
        artist.image_lastfm = artist_info['image'][2]['#text']
        artist.update
        fave = Favorite.where(user: self, artist: artist, timeframe: timeframe).first_or_create
        fave.rank = artist_info['@attr']['rank'].to_i
        fave.playcount = artist_info['playcount']
        fave.save
      end
    else
      false
    end
  end

  def top_artists(timeframe = FAVORITES_TIMEFRAME, number = 10)
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
    # user.update_favorites
    user
  end

  private

  def email_required?
    false
  end

  def get_user_info
    result = lastfm_query(
      method: 'user.getinfo',
      user: username
    )
    result ? result['user'] : false
  end

  def get_top_artists(timeframe, number)
    result = lastfm_query(
      method: 'user.gettopartists',
      user: username,
      period: timeframe,
      limit: number
    )
    result ? result['topartists']['artist'] : false
  end

  def lastfm_query(params)
    params = params.merge(
      api_key: ENV['LASTFM_KEY'],
      format: 'json'
    )
    response = self.class.get('', query: params)
    response.keys.include?('error') ? false : response
  rescue
    false
  end
end
