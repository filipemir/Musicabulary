class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params['id'])
    response = if @artist
      {
        status: '200',
        wordiness: @artist.wordiness,
        total_words: @artist.total_words,
        word_sample_size: WORD_SAMPLE_SIZE
      }
    else
      { status: '404' }
    end
    render json: response
  end
end
