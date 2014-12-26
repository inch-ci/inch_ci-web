class SessionsController < ApplicationController
  def create
    action = Action::User::Signin.new(request)
    self.current_user = action.user
    redirect_to welcome_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
