require 'inch_ci/access_token'

if InchCI::AccessToken[:github_client_id]
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, InchCI::AccessToken[:github_client_id],
                      InchCI::AccessToken[:github_secret], :scope => 'user:email,write:repo_hook'
  end
end
