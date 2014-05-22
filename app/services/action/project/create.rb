require 'inch_ci/action'

module Action
  module Project
    class Create
      include InchCI::Action

      exposes :project

      def initialize(params)
        info = InchCI::RepoURL.new(params[:repo_url])
        if @project = InchCI::Store::EnsureProject.call(info.url)
          if @project = update_project
            if branch = InchCI::Store::FindDefaultBranch.call(@project)
              @build = InchCI::Worker::Project::Build.enqueue(project.repo_url, branch.name)
            end
          end
        end
      end

      def build_id
        return unless success?
        @build.id
      end

      def success?
        !@project.nil? && !@project.name.nil?
      end

      private

      def update_project
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(@project.uid)
        InchCI::Store::FindProject.call(@project.uid)
      end
    end
  end
end
