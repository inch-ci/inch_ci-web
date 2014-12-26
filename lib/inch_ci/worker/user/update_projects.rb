require 'inch_ci/git_hub_info'

module InchCI
  module Worker
    module User
      # The UpdateProjects worker is responsible for updating a user's
      # projects.
      class UpdateProjects
        include Sidekiq::Worker

        ORIGIN = 'github_sync'

        # @param id [Fixnum] the user's ID
        # @return [void]
        def self.enqueue(id)
          perform_async(id)
        end

        # @api private
        def perform(id)
          user = Store::FindUserById.call(id)
          service_name = user.provider
          user_name = user.user_name
          if service_name == "github"
            update_via_github(user, user_name)
          end
        end

        private

        def update_via_github(user, user_name)
          github = GitHubInfo.user(user_name)

          github.repos.each do |_repo|
            repo = GitHubInfo::Repo.new(_repo)
            unless repo.fork?
              project = ensure_project_and_branch(repo.url, repo.default_branch)
              update_project(project, repo)
            end
          end

          Store::UpdateLastProjectSync.call(user)
        end

        def ensure_project_and_branch(url, branch_name)
          project = Store::EnsureProject.call(url, ORIGIN)
          Store::FindBranch.call(project, branch_name) ||
            Store::CreateBranch.call(project, branch_name)
          project
        end

        def update_project(project, repo)
          Worker::Project::UpdateInfo.new.perform(project.uid, repo)
        end
      end
    end
  end
end
