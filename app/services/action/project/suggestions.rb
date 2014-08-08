module Action
  module Project
    class Suggestions < Show
      FILE_COUNT          = 5
      GRADES_TO_DISPLAY   = %w(B C U)
      GRADE_WEIGHTS       = [0.2, 0.4, 0.4]
      MIN_PRIORITY        = 0

      exposes :project, :branch, :revision, :collection, :suggestion_count
      exposes :suggestions, :files

      def initialize(params)
        super
        if @code_objects
          suggested = filter_suggested_code_objects(@code_objects)
          @suggestions = InchCI::GradeListCollection.new(suggested)
          files = suggested.map(&:filename)
          @files = sort_files_by_frequency(files)[0...FILE_COUNT]
        end
      end

      private

      def sort_files_by_frequency(filenames)
        filenames.uniq.map do |f|
          count = filenames.select { |fn| fn == f }.size
          [count, f]
        end.sort.reverse.map(&:last)
      end

      def filter_suggested_code_objects(code_objects)
        graded_list = GRADES_TO_DISPLAY.map do |grade|
          code_objects.select do |code_object|
            code_object.grade == grade &&
              code_object.priority >= MIN_PRIORITY
          end
        end

        weighted_list = ::Inch::Utils::WeightedList.new(graded_list, object_list_counts)

        list = ::Inch::Codebase::Objects.sort_by_priority(weighted_list.to_a.flatten)

        list = list[0...object_count] if list.size > MAX_SUGGESTIONS
        list
      end

      # @return [Array<Fixnum>]
      #   how many objects of each grade should be displayed in the output
      def object_list_counts
        GRADE_WEIGHTS.map { |w| w * MAX_SUGGESTIONS }
      end
    end
  end
end
