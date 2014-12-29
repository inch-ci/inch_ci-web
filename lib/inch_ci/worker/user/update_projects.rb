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

          repos = github.repos.map do |_repo|
            repo = GitHubInfo::Repo.new(_repo)
            repo.fork? ? nil : repo
          end.compact
          find_not_existing_repos(repos).each do |repo|
            project = create_project_and_branch(repo.url, repo.default_branch)
            update_project(project, repo, user)
          end

          Store::UpdateLastProjectSync.call(user)
        end

        def find_not_existing_repos(repos)
          all_uids = repos.map { |r| "github:#{r.name}" }
          existing = ::Project.where(:uid => all_uids).pluck(:uid)
          p :EXISTING => existing
          repos.reject { |r| existing.include?("github:#{r.name}") }
        end

        def create_project_and_branch(url, branch_name)
          info = RepoURL.new(url)
          return if info.project_uid.nil?
          project = Store::CreateProject.call(info.project_uid, info.url, ORIGIN)
          Store::CreateBranch.call(project, branch_name)
          project
        end

        def update_project(project, repo, user)
          Worker::Project::UpdateInfo.new.perform(project.uid, repo)
        end
      end
    end
  end
end
