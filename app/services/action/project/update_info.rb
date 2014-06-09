require 'inch_ci/action'

module Action
  module Project
    class UpdateInfo
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch

      def initialize(params)
        set_project_and_branch(params)
        update_project
      end

      private

      def update_project
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(@project.uid)
      end
    end
  end
end
