class UserPresenter < BasePresenter
  def_delegators :user, :display_name, :user_name, :email, :provider

  use_presenters :projects

  def name
    display_name
  end

  def service_name
    provider
  end
end
