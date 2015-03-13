module InchCI
  class GradeListCollection
    include Enumerable

    GRADES = %w(A B C U)

    def initialize(code_objects)
      @count = code_objects.count
      @grade_lists = create_grade_lists(code_objects)
      @grade_percentages = calculate_grade_percentages(@grade_lists)
    end

    def [](grade)
      @grade_lists[grade]
    end

    def each(&block)
      GRADES.each do |grade|
        block.call(@grade_lists[grade])
      end
    end

    def percent(grade)
      @grade_percentages[grade.to_s]
    end

    private

    def create_grade_lists(code_objects)
      grade_lists = {}
      GRADES.each do |grade|
        grade_lists[grade] = GradeList.new(grade, code_objects)
      end
      grade_lists
    end

    def calculate_grade_percentages(grade_lists)
      grade_percentages = {}
      GRADES.each do |grade|
        v = @count == 0 ? 0 : (grade_lists[grade.to_s].count / @count.to_f)
        grade_percentages[grade.to_s] = (v * 100).to_i
      end

      residual = 100 - grade_percentages.values.inject(:+)
      GRADES.reverse.each do |grade|
        if grade_percentages[grade.to_s] > 0
          grade_percentages[grade.to_s] += residual
          break
        end
      end

      grade_percentages
    end
  end

  class GradeList
    attr_reader :code_objects, :count, :grade

    def initialize(grade, code_objects)
      code_objects ||= []
      @grade = grade
      @code_objects = code_objects.select { |o| o.grade == grade }
      @count = @code_objects.count
    end
  end
end
