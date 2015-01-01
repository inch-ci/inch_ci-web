require 'inch_ci/action'

module Action
  module Project
    class RemoveHook
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project

      def initialize(user, params)
        set_project_and_branch(params)
        if user_access_token = user.github_access_token
          update_via_github(@project.to_model, user_access_token)
        else
          raise "Need access token!"
        end
      end

      def success?
        !@success.nil?
      end

      private

      def update_via_github(project, user_access_token)
        client = Octokit::Client.new(access_token: user_access_token)
        removed = client.remove_hook(project.name, project.github_hook_id)
        if removed
          project.github_hook_id = nil
          InchCI::Store::SaveProject.call(project)
          @success = true
        end
      end
    end
  end
end
