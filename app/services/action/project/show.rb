require 'inch_ci/action'
require 'inch_ci/grade_list_collection'

module Action
  module Project
    class Show
      include InchCI::Action
      include Action::SetProjectAndBranch

      MAX_SUGGESTIONS = 20

      exposes :project, :branch, :revision, :collection, :suggestion_count, :pending_build

      def initialize(params)
        set_project_and_branch(params)
        @build = find_pending_build(params)
        if revision = find_revision(@branch, params)
          @revision = RevisionPresenter.new(revision)
          @code_objects = find_code_objects(revision)
          @collection = create_collection(@code_objects)
          @suggestion_count = @code_objects.select do |code_object|
              code_object.grade != 'A'
            end.size
          if @suggestion_count > MAX_SUGGESTIONS
            @suggestion_count = "#{MAX_SUGGESTIONS}+"
          end
        end
      end

      private

      def find_code_objects(revision)
        return if revision.nil?
        list = InchCI::Store::FindRelevantCodeObjects.call(revision)
        present_code_objects(list)
      end

      def create_collection(code_objects)
        return if code_objects.empty?
        InchCI::GradeListCollection.new(code_objects)
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

      def present_code_objects(code_objects)
        code_objects.map { |o| CodeObjectPresenter.new(o) }
      end
    end
  end
end
