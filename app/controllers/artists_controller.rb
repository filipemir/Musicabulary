class ArtistsController < ApplicationController
  def index
    @artists = current_user.top_artists
  end

  def show
    @artist = Artist.find(params['id'])
    if @artist
      response = {
        status: '200',
        wordiness: @artist.wordiness
      }
    else
      response = { status: '404' }
    end
    render json: response
  end
end
