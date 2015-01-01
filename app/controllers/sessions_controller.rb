class SessionsController < ApplicationController
  def create
    p :AUTH => request.env["omniauth.auth"]
    action = Action::User::Signin.new(request)
    self.current_user = action.user
    redirect_to action.new_user? ? welcome_url : user_url(current_user)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
