module InchCI
  class GradeListCollection
    include Enumerable

    GRADES = %w(A B C U)

    def initialize(code_objects)
      @count = code_objects.count
      @grade_lists = {}
      GRADES.each do |grade|
        @grade_lists[grade] = GradeList.new(grade, code_objects)
      end
    end

    def each(&block)
      GRADES.each do |grade|
        block.call(@grade_lists[grade])
      end
    end

    def percent(grade)
      return nil if @count == 0
      v = @grade_lists[grade.to_s].count / @count.to_f
      (v * 100).to_i
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
