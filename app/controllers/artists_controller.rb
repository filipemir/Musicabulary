class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params['id'])
    @total_words = @artist.total_words
    @wordiness = @artist.wordiness
    if @artist
      response = {
        status: '200',
        wordiness: @wordiness
      }
    else
      response = { status: '404' }
    end
    render json: response
  end
end
