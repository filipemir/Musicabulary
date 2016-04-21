class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def lastfm
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      @user.update
      sign_in @user
      flash[:success] = "Hello!"
      redirect_to artists_path
    else
      flash[:error] = "Oops. Login failed."
      redirect_to root_path
    end
  end
end