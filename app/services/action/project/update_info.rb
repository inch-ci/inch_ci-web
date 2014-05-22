require 'inch_ci/action'

module Action
  module Project
    class UpdateInfo
      include InchCI::Action
      include Action::FindProjectAndBranch

      exposes :project, :branch

      def initialize(params)
        @project = find_project(params)
        @branch = find_branch(@project, params)
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
