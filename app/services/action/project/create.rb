require 'inch_ci/action'

module Action
  module Project
    class Create
      include InchCI::Action

      exposes :project

      def initialize(params, origin = nil)
        return unless params[:repo_url].present?

        info = InchCI::RepoURL.new(params[:repo_url])
        if info.repo_url.nil?
          info = InchCI::RepoURL.new("https://github.com/#{params[:repo_url]}")
        end
        if @project = InchCI::Store::EnsureProject.call(info.repo_url, origin)
          if @project = update_project(@project)
            if branch = InchCI::Store::FindDefaultBranch.call(@project)
              create_build_if_possible(@project, branch)
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

      def create_build_if_possible(project, branch)
        if InchCI::Worker::Project.build_on_inch_ci?(project.language)
          @build = InchCI::Worker::Project::Build.enqueue(project.repo_url, branch.name)
        end
      end

      def update_project(project)
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(project.uid)
        InchCI::Store::FindProject.call(project.uid)
      end
    end
  end
end
