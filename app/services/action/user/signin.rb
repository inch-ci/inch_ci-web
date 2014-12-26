require 'inch_ci/action'

module Action
  module User
    class Signin
      include InchCI::Action

      CLIENT_ID     = InchCI::AccessToken[:github_client_id]
      CLIENT_SECRET = InchCI::AccessToken[:github_secret]

      exposes :user

      def initialize(request)
        @user = find_or_create_user(request.env["omniauth.auth"])
        if @user.last_signin_at.nil?
          # sync_and_build_projects
        end
      end

      private

      def follows(user)
        client = Octokit::Client.new(:access_token => user.github_access_token)
        list = client.following(user.user_name)
        list.map { |h| h['login'] }
      end

      def find_or_create_user(auth)
        user = ::User.find_or_create_with_omniauth(auth)
        update_user user, auth
        user
      end

      def update_user(user, auth)
        user.github_access_token = auth["credentials"]["token"]
        user.last_signin_at = Time.now
        user.follows = follows(user) if user.follows.nil?
        user.save
      end
    end
  end
end
