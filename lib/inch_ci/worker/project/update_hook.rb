require 'inch_ci/git_hub_info'

module InchCI
  module Worker
    module Project
      # The UpdateInfo worker is responsible for updating a project's
      # meta information, like homepage and documentation URLs.
      class UpdateHook
        include Sidekiq::Worker

        REBUILD_URL_PATTERN = /https*\:\/\/inch-ci\.org\/rebuild/

        # @param uid [String]
        # @return [void]
        def self.enqueue(uid, user_access_token)
          perform_async(uid, user_access_token)
        end

        # @api private
        # @param github_repo_object [] used to directly update a project
        def perform(uid, user_access_token)
          project = Store::FindProject.call(uid)
          arr = uid.split(':')
          service_name = arr[0]
          user_repo_name = arr[1]
          if service_name == "github"
            update_via_github(project, user_access_token)
          end
        end

        private

        def update_via_github(project, user_access_token)
          client = Octokit::Client.new(access_token: user_access_token)
          hooks = client.hooks(project.name)
          p :HOOKS => hooks
          hooks.each do |hash|
            if hash['config'] && hash['config']['url'] =~ REBUILD_URL_PATTERN
              project.github_hook_id = hash['id']
            end
          end

          Store::SaveProject.call(project)
        end
      end
    end
  end
end
