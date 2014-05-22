require_relative 'update_info/git_hub_info'

module InchCI
  module Worker
    module Project
      class UpdateInfo
        include Sidekiq::Worker

        def self.enqueue(*args)
          perform_async(*args)
        end

        def perform(uid)
          project = Store::FindProject.call(uid)
          arr = uid.split(':')
          service_name = arr[0]
          user_repo_name = arr[1]
          if service_name == "github"
            update_via_github(project, user_repo_name)
          end
        end

        def update_via_github(project, user_repo_name)
          github = GitHubInfo.new(user_repo_name)

          project.name = github.name
          project.description = github.description
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
