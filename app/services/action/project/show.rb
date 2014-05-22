require 'inch_ci/action'
require 'inch_ci/grade_list_collection'

module Action
  module Project
    class Show
      include InchCI::Action
      include Action::FindProjectAndBranch

      exposes :project, :branch, :revision, :collection, :pending_build

      def initialize(params)
        @build = find_pending_build(params)
        @project = find_project(params)
        @branch = find_branch(@project, params)
        if revision = find_revision(@branch, params)
          @revision = RevisionPresenter.new(revision)
          @collection = create_collection(@revision)
        end
      end

      private

      def create_collection(revision)
        return if revision.nil?
        code_objects = InchCI::Store::FindCodeObjects.call(revision)
        code_objects = code_objects.map { |o| CodeObjectPresenter.new(o) }
        @collection = InchCI::GradeListCollection.new(code_objects)
      end

      def find_pending_build(params)
        if uid = params[:pending_build]
          build = InchCI::Store::FindBuild.call(uid)
          unless build.finished_at
            @pending_build = build
          end
        end
      end

      def find_revision(branch, params)
        return if branch.nil?
        if revision_uid = params[:revision]
          InchCI::Store::FindRevision.call(@branch, revision_uid)
        else
          InchCI::Store::FindLatestRevision.call(@branch)
        end
      end
    end
  end
end
