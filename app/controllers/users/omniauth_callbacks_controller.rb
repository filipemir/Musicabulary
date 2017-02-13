class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def lastfm
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user && @user.persisted?
      @user.update_favorites
      @user.update_info
      sign_in @user
      flash[:success] = "Hello!"
      redirect_to favorites_path
    else
      flash[:success] = "Sorry! Something went wrong and I was unable to log you in :("
      redirect_to unauthenticated_root_path
    end
  end
end