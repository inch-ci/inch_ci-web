require 'inch_ci/action'

module Action
  module Project
    class Rebuild
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch, :build

      def initialize(params)
        set_project_and_branch(params)
        if @project && @branch
          # maybe we should check of there is a build running for this branch?
          @build = InchCI::Worker::Project::Build.enqueue(@project.repo_url, @branch.name)
        end
      end

      def build_id
        @build.id
      end
    end
  end
end
