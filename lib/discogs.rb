module Discogs
  def self.included(receiving_class)
    receiving_class.send :include, Faraday
  end

  def get_discogs_id
    response = discogs_query('/database/search', q: name)
    if response
      response['results'].each do |result|
        type = result['type']
        id = result ['id']
        return id if type == 'artist'
      end
    end
    nil
  end

  def get_discogs_image
    response = discogs_query('/artists/' + discogs_id.to_s)
    if response
      images = response['images']
      return images.first['uri'] if images
    end
    nil
  end

  def get_artist_records_page(page_num)
    discogs_query(
      '/artists/' + discogs_id.to_s + '/releases',
      sort: 'year',
      sort_order: 'asc',
      page: page_num,
      per_page: 100
    )
  rescue
    false
  end

  def get_record_songs
    record = discogs_query('/masters/' + discogs_id.to_s)
    record ? record['tracklist'] : false
  end

  def discogs_query(path, params = {})
    params = params.merge(token: ENV['DISCOGS_TOKEN'])
    response = Faraday.get('https://api.discogs.com' + path, params)
    success = response.status == 200
    success ? JSON.parse(response.body) : false
  rescue
    puts 'Discogs request failed'
    false
  end
end
