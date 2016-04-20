class SessionsController < Devise::SessionsController
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    flash[:notice] = "Goodbye!" if signed_out
    redirect_to new_user_session_path
  end
end
