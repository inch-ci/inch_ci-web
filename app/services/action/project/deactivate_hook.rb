require 'inch_ci/action'

module Action
  module Project
    class DeactivateHook
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project

      def initialize(user, params)
        set_project_and_branch(params)
        if user_access_token = user.github_access_token
          process_via_github(@project.to_model, user_access_token)
        else
          raise "Need access token!"
        end
      end

      def success?
        !@success.nil?
      end

      private

      def process_via_github(project, user_access_token)
        client = Octokit::Client.new(access_token: user_access_token)
        if project.github_hook_id
          response = client.edit_hook(project.name, project.github_hook_id,
                        hook_service, hook_url_config, hook_deactivate_options)
          p :RESPONSE => response
          if response.active == false
            project.github_hook_active = false
            InchCI::Store::SaveProject.call(project)
            @success = true
          end
        end
      end

      include Action::Project::ActivateHook::HookConfig
    end
  end
end
