require 'inch_ci/action'

module Action
  module Project
    class CreateHook
      include InchCI::Action
      include Action::SetProjectAndBranch

      HOOK_URL = 'http://inch-ci.org/rebuild'

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
        !@project.github_hook_id.nil?
      end

      private

      def update_via_github(project, user_access_token)
        client = Octokit::Client.new(access_token: user_access_token)
        hook = client.create_hook(project.name, 'web', hook_url_config,
                                                                  hook_options)
        project.github_hook_id = hook.id
        InchCI::Store::SaveProject.call(project)
      end

      def hook_url_config
        {url: HOOK_URL, content_type: 'json'}
      end

      def hook_options
        {events: ['push'], active: true}
      end
    end
  end
end
