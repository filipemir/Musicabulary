# module LastFM
#   def self.included(receiving_class)
#     receiving_class.send :include, HTTParty
#     receiving_class.send :base_uri, 'https://api.discogs.com/'
#   end

#   def get_user_info
#     binding.pry
#     result = lastfm_query(
#       method: 'user.getinfo',
#       user: username
#     )
#     result ? result['user'] : false
#   end

#   def get_top_artists(timeframe, number)
#     result = lastfm_query(
#       method: 'user.gettopartists',
#       user: username,
#       period: timeframe,
#       limit: number
#     )
#     result ? result['topartists']['artist'] : false
#   end

#   def lastfm_query(params)
#     begin
#       params = params.merge(
#         api_key: ENV['LASTFM_KEY'], 
#         format: 'json'
#       )
#       response = self.class.get('', query: params)
#       response.keys.include?('error')? false : response
#     rescue
#       false
#     end
#   end
# end