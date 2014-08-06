module Action
  module Project
    class Suggestions < Show

      exposes :project, :branch, :revision, :collection, :suggestion_count, :suggestions

      def initialize(params)
        super
        if @code_objects
          suggested = filter_suggested_code_objects(@code_objects)
          @suggestions = InchCI::GradeListCollection.new(suggested)
        end
      end

      private

      def filter_suggested_code_objects(code_objects)
        list = code_objects.select do |code_object|
            code_object.grade != 'A'
          end
        list[0...MAX_SUGGESTIONS]
      end
    end
  end
end
