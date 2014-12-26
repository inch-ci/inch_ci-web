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
          sync_and_build_projects
        end
        update_user @user, request.params
      end

      private

      def follows
        client = Octokit::Client.new(:access_token => @user.github_access_token)
        list = client.following(@user.user_name)
        list.map { |h| h['login'] }
      end

      def find_or_create_user(auth)
        ::User.find_or_create_with_omniauth(auth)
      end

      def github_access_token(params)
        client = Octokit::Client.new
        token_response = client.exchange_code_for_token params[:code], CLIENT_ID, CLIENT_SECRET
        token_response['access_token']
      end

      def update_user(user, params)
        attributes = {
          :github_access_token => github_access_token(params),
          :last_signin_at => Time.now,
        }
        attributes[:follows] = follows if @user.follows.nil?
        user.update_attributes(attributes)
      end
    end
  end
end
