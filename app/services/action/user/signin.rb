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
        @new_user = @user.last_signin_at.nil?
        @user.last_signin_at = Time.now
        InchCI::Store::SaveUser.call(@user)
      end

      def new_user?
        @new_user
      end

      private

      def follows(user)
        client = Octokit::Client.new(:access_token => user.github_access_token)
        list = client.following(user.user_name)
        list.map { |h| h['login'] }
      end

      def find_or_create_user(auth)
        user = ::User.find_or_create_with_omniauth(auth)
        user.github_access_token = auth["credentials"]["token"]
        user.display_name = auth["info"]["name"]
        user.user_name = auth["info"]["nickname"]
        user.email = auth["info"]["email"]
        user.follows = follows(user) if user.follows.nil?
        user
      end
    end
  end
end
