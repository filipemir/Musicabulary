class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def lastfm
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      @user.update_favorites
      @user.update_info
      sign_in @user
      flash[:success] = "Hello!"
      redirect_to favorites_path
    end
  end
end