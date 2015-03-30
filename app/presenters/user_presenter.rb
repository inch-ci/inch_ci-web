class UserPresenter < BasePresenter
  def_delegators :user, :display_name, :user_name, :email, :provider, :follows,
                        :last_synced_projects_at, :last_signin_at,
                        :github_access_token, :organizations

  use_presenters :projects

  def github_url
    "https://github.com/#{user_name}"
  end

  def name
    display_name
  end

  def service_name
    provider
  end
end
