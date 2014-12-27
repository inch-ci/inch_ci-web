require 'inch_ci/action'

module Action
  module User
    class Signin
      include InchCI::Action

      CLIENT_ID     = InchCI::AccessToken[:github_client_id]
      CLIENT_SECRET = InchCI::AccessToken[:github_secret]

      TRIGGER = 'first_signin'

      exposes :user

      def initialize(request)
        @user = find_or_create_user(request.env["omniauth.auth"])
        if @user.last_signin_at.nil?
          # sync_and_build_projects
          t1 = Time.now.to_f
          InchCI::Worker::User::UpdateProjects.new.perform(@user.id)
          projects = InchCI::Store::FindAllProjects.call(@user)
          projects.each do |project|
            if project.language == 'Ruby'
              InchCI::Worker::Project::UpdateHook.enqueue project.uid, @user.github_access_token
              InchCI::Worker::Project::Build.enqueue project.repo_url, project.default_branch.name, nil, TRIGGER
            end
          end
          t2 = Time.now.to_f
          p :DIFF => t2-t1
        end
        @user.last_signin_at = Time.now
        @user.save
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
        user.follows = follows(user) if user.follows.nil?
        user
      end
    end
  end
end
