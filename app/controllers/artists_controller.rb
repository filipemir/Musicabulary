class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params['id'])
    @total_words = @artist.total_words
    @wordiness = @artist.wordiness
    response = if @artist
      {
        status: '200',
        wordiness: @wordiness
      }
    else
      { status: '404' }
    end
    render json: response
  end
end
