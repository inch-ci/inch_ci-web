require 'inch_ci/action'

module Action
  module Project
    class UpdateInfo
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch

      def initialize(current_user, params)
        set_project_and_branch(params)
        update_project
        if current_user && @project.user_name == current_user.user_name
          update_hook(current_user.github_access_token)
        end
      end

      private

      def update_project
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(@project.uid)
      end

      def update_hook(user_access_token)
        worker = InchCI::Worker::Project::UpdateHook.new
        worker.perform(@project.uid, user_access_token)
      end
    end
  end
end
