class FavoritesController < ApplicationController
  def index
    @artists = current_user.top_artists
  end

  def show
    @artist = @favorite.find(params['artist_id'])
    binding.pry
    if @artist
      response = {
        status: '200',
        image: @artist.image_discogs,
        wordiness: @artist.wordiness
      }
    else 
      response = { status: '404' }
    end
    render json: response
  end
end
