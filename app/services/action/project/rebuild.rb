require 'inch_ci/action'

module Action
  module Project
    class Rebuild
      include InchCI::Action
      include Action::FindProjectAndBranch

      exposes :project, :branch, :build

      def initialize(params)
        @project = find_project(params)
        @branch = find_branch(@project, params)
        # maybe we should check of there is a build running for this branch?
        @build = InchCI::Worker::Project::Build.enqueue(@project.repo_url, @branch.name)
      end

      def build_id
        @build.id
      end
    end
  end
end
