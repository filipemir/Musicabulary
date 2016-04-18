class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def lastfm
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in_and_redirect @user
      flash[:success] = "Hello, #{@user.uid}!"
    else
      flash[:error] = "Oops. Login failed."
      redirect_to root_path
    end
  end
end