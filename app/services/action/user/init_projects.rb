require 'inch_ci/action'

module Action
  module User
    class InitProjects
      include InchCI::Action

      exposes :user, :projects

      ORIGIN = 'github_sync'
      TRIGGER = 'first_signin'

      def initialize(current_user, params)
        @user = current_user.to_model
        if @user.last_synced_projects_at.nil?
          t1 = Time.now.to_f

          InchCI::Store::UpdateLastProjectSync.call(@user)
          if @user.provider == "github"
            update_projects_via_github(@user)
          end

          find_ruby_projects.each do |project|
            update_hook(project)
          end.each do |project|
            build(project)
          end
          t2 = Time.now.to_f

          Rails.logger.info "InitProjects: user=#{@user.user_name} projects=#{@user.projects.count} delta=#{t2-t1}"
        end
      end

      private

      def update_projects_via_github(user)
        github = InchCI::GitHubInfo.user(user.user_name)

        repos = github.repos.map do |_repo|
          repo = InchCI::GitHubInfo::Repo.new(_repo)
          repo.fork? ? nil : repo
        end.compact
        find_not_existing_repos(repos).each do |repo|
          project = create_project_and_branch(repo.url, repo.default_branch)
          update_project_info(project, repo, user)
        end
      end

      def find_not_existing_repos(repos)
        all_uids = repos.map { |r| "github:#{r.name}" }
        existing = ::Project.where(:uid => all_uids).pluck(:uid)
        repos.reject { |r| existing.include?("github:#{r.name}") }
      end

      def create_project_and_branch(url, branch_name)
        info = InchCI::RepoURL.new(url)
        return if info.project_uid.nil?
        project = InchCI::Store::CreateProject.call(info.project_uid, info.url, ORIGIN)
        InchCI::Store::CreateBranch.call(project, branch_name)
        project
      end

      def update_project_info(project, repo, user)
        InchCI::Worker::Project::UpdateInfo.new.perform(project.uid, repo)
      end

      def find_ruby_projects
        InchCI::Store::FindAllProjects.call(@user).select do |project|
          project.language == 'Ruby'
        end
      end

      def update_hook(project)
        InchCI::Worker::Project::UpdateHook.enqueue project.uid, @user.github_access_token
      end

      def build(project)
        InchCI::Worker::Project::Build.enqueue project.repo_url, project.default_branch.name, nil, TRIGGER
      end
    end
  end
end
