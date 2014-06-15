require 'inch_ci/project_uid'

module InchCI
  module Action
    def self.included(other)
      other.extend(ClassMethods)
    end

    def exposures
      self.class.exposures
    end

    module ClassMethods
      attr_accessor :exposure_map

      def exposes(*names)
        exposures.concat names
        attr_reader *names
      end

      def exposures
        self.exposure_map ||= {}
        self.exposure_map[self.to_s] ||= []
      end
    end

    class FindProjectAndBranch
      attr_reader :project, :branch

      def self.call(*args)
        new(*args)
      end

      def initialize(params)
        uid = ProjectUID.new(params).project_uid
        @project = InchCI::Store::FindProject.call(uid)
        @branch = find_branch(params[:branch]) if !@project.nil?
      end

      private

      def find_branch(branch_name)
        if branch_name
          InchCI::Store::FindBranch.call(project, branch_name)
        else
          InchCI::Store::FindDefaultBranch.call(project)
        end
      end
    end

    class EnsureProjectAndBranch
      attr_reader :project, :branch

      def self.call(*args)
        new(*args).branch
      end

      def initialize(url_or_params, branch_name)
        @branch = InchCI::Store::EnsureProjectAndBranch.call(project_url(url_or_params), branch_name)
        @project = branch.project
        update_project(@project) if !@project.default_branch
      end

      private

      def project_url(url_or_params)
        if url_or_params.is_a?(Hash)
          ProjectUID.new(url_or_params).repo_url
        else
          RepoURL.new(url_or_params).repo_url
        end
      end

      def update_project(project)
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(project.uid)
      end
    end
  end
end

