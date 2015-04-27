require 'inch_ci/action'
require 'inch_ci/grade_list_collection'

module Action
  module Project
    class History < Show
      include InchCI::Action
      include Action::SetProjectAndBranch

      exposes :project, :branch, :revision, :collection, :suggestion_count
      exposes :builds, :diffs, :code_object_map

      def initialize(params)
        super
        if @revision
          @builds = present(find_builds, BuildPresenter)
          @diffs = @builds.map(&:revision_diff).compact
          @code_object_map = create_code_object_map(@diffs)
        end
      end

      private

      def create_code_object_map(revision_diffs)
        code_object_map = {}

        code_object_ids = revision_diffs.flat_map do |rev_diff|
          rev_diff.to_model.code_object_diffs.flat_map do |obj_diff|
            [obj_diff.before_object_id, obj_diff.after_object_id]
          end
        end
        ::CodeObject.where(:id => code_object_ids).each do |code_object|
          code_object_map[code_object.id] = CodeObjectPresenter.new(code_object)
        end
        code_object_map
      end

      def find_builds
        InchCI::Store::FindBuildsInBranch.call(@branch)
      end

      def present(list, presenter_class)
        list.map { |diff| presenter_class.new(diff) }
      end

      def limit(list, max_count = 50)
        count = 0
        result = []
        list.each do |rev_diff|
          count += 1 if rev_diff.change_count > 0
          result << rev_diff
          if count >= max_count
            return result
          end
        end
        result
      end
    end
  end
end
