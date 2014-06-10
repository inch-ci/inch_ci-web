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
        names.each do |name|
          send :attr_reader, name
        end
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
        @branch = find_branch(params[:branch]) if project
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

      def initialize(project_url, branch_name)
        @branch = InchCI::Store::EnsureProjectAndBranch.call(project_url, branch_name)
        @project = branch.project
        update_project(@project) if !@project.default_branch
      end

      def update_project(project)
        worker = InchCI::Worker::Project::UpdateInfo.new
        worker.perform(project.uid)
      end
    end
  end
end

