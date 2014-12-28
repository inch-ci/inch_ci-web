require 'inch_ci/action'

module Action
  module User
    class InitProjects
      include InchCI::Action

      exposes :user, :projects

      TRIGGER = 'first_signin'

      def initialize(current_user, params)
        @user = current_user
        if @user.last_synced_projects_at.nil?
          t1 = Time.now.to_f
          InchCI::Worker::User::UpdateProjects.new.perform(@user.id)
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
