require 'inch_ci/action'

module Action
  module Project
    class ActivateHook
      include InchCI::Action
      include Action::SetProjectAndBranch

      TRIGGER = 'activate_hook'

      exposes :project

      def initialize(user, params)
        set_project_and_branch(params)
        if user_access_token = user.github_access_token
          process_via_github(@project.to_model, user_access_token)
          if @project.to_model.builds.count == 0
            build(project)
          end
        else
          raise "Need access token!"
        end
      end

      def success?
        !@project.github_hook_id.nil?
      end

      private

      def build(project)
        InchCI::Worker::Project::Build.enqueue project.repo_url, project.default_branch.name, nil, TRIGGER
      end

      def process_via_github(project, user_access_token)
        client = Octokit::Client.new(access_token: user_access_token)
        if project.github_hook_id
          response = client.edit_hook(project.name, project.github_hook_id,
                          hook_service, hook_url_config, hook_activate_options)
        else
          hook = client.create_hook(project.name, hook_service,
                                          hook_url_config, hook_create_options)
          project.github_hook_id = hook.id
        end
        project.github_hook_active = true
        InchCI::Store::SaveProject.call(project)
      end

      module HookConfig
        HOOK_URL = 'http://inch-ci.org/rebuild'

        def hook_service
          'web'
        end

        def hook_url_config
          {url: HOOK_URL, content_type: 'json'}
        end

        def hook_create_options
          {events: ['push'], active: true}
        end

        def hook_activate_options
          {active: true}
        end

        def hook_deactivate_options
          {active: false}
        end
      end
      include HookConfig
    end
  end
end
