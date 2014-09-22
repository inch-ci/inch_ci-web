require 'inch_ci/worker/project/update_info/git_hub_info'

module InchCI
  module Worker
    module Project
      # The UpdateInfo worker is responsible for updating a project's
      # meta information, like homepage and documentation URLs.
      class UpdateInfo
        include Sidekiq::Worker

        # @param uid [String]
        # @return [void]
        def self.enqueue(uid)
          perform_async(uid)
        end

        # @api private
        def perform(uid)
          project = Store::FindProject.call(uid)
          arr = uid.split(':')
          service_name = arr[0]
          user_repo_name = arr[1]
          if service_name == "github"
            update_via_github(project, user_repo_name)
          end
        end

        private

        def update_via_github(project, user_repo_name)
          github = GitHubInfo.new(user_repo_name)

          project.name = github.name
          project.description = github.description
          project.language = github.language
          project.homepage_url = github.homepage_url
          project.documentation_url = github.documentation_url
          project.source_code_url = github.source_code_url

          Store::SaveProject.call(project)

          default_branch = ensure_branch(project, github.default_branch)
          Store::UpdateDefaultBranch.call(project, default_branch)

          github.branches.each do |branch_name|
            ensure_branch(project, branch_name)
          end
        rescue Octokit::NotFound

        end

        def ensure_branch(project, branch_name)
          Store::FindBranch.call(project, branch_name) ||
            Store::CreateBranch.call(project, branch_name)
        end
      end
    end
  end
end
