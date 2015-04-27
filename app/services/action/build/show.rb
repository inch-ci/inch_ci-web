require 'inch_ci/action'

module Action
  module Build
    class Show
      include InchCI::Action

      exposes :build, :code_object_map, :filename, :dump

      def initialize(params, load_dump: false, load_diff: false)
        if uid = params[:id]
          @build = BuildPresenter.new(InchCI::Store::FindBuild.call(uid))
          if load_diff && @build.revision_diff
            @code_object_map = create_code_object_map([@build.revision_diff])
          end
          if load_dump
            load_dump_if_present
          end
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

      def load_dump_if_present
        @filename = Rails.root.join('dumps', 'builds', "build-#{@build.id}.json")
        @dump = File.read(@filename) if File.exist?(@filename)
      end
    end
  end
end
