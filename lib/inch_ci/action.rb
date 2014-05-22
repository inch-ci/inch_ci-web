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
  end
end

