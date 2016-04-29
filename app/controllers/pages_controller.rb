class PagesController < ApplicationController
  layout false

  def show
    @lastfm = User.find_by(username: 'last.fm')
    @artists = @lastfm.top_artists('')
    render template: "pages/#{params[:page]}"
  end
end
