module LastFM
  def self.included(receiving_class)
    receiving_class.send :include, HTTParty
    receiving_class.send :base_uri, 'http://ws.audioscrobbler.com/2.0/'
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

  def get_lastfm_top_artists(number, page)
    result = lastfm_query(
      method: 'chart.gettopartists',
      limit: number,
      page: page
    )
    result ? result['artists']['artist'] : false
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
