require 'inch_ci/access_token'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, InchCI::AccessToken[:github_key],
                    InchCI::AccessToken[:github_secret], :scope => 'user:email'
end
