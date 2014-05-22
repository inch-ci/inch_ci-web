module InchCI
  class Diff
    def initialize(objects1, objects2)
      @objects1, @objects2 = objects1, objects2
    end

    def comparisons
      __objects_names.map do |fullname|
        object1 = @objects1.detect { |o| o.fullname == fullname }
        object2 = @objects2.detect { |o| o.fullname == fullname }
        CompareCodeObjects.new(object1, object2)
      end
    end

    private

    def __objects_names
      fullnames = @objects1.map(&:fullname) +
                @objects2.map(&:fullname)
      fullnames.uniq
    end

    class CompareCodeObjects
      attr_reader :before, :after

      def initialize(object1, object2)
        @before, @after = object1, object2
        if @before.object_id == @after.object_id
          raise "@before and @after are identical ruby objects. this is bad."
        end
      end

      def change
        return 'added' if added?
        return 'improved' if improved?
        return 'degraded' if degraded?
        return 'removed' if removed?
      end

      def changed?
        present? && !unchanged?
      end

      def added?
        @before.nil? && !@after.nil?
      end

      def degraded?
        changed? && @before.score > @after.score
      end

      def improved?
        changed? && @before.score < @after.score
      end

      def present?
        @before && @after
      end

      def removed?
        !@before.nil? && @after.nil?
      end

      def unchanged?
        present? && @before.score == @after.score
      end
    end
  end
end
