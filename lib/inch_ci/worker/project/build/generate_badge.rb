require 'fileutils'
require 'inch_ci/badge'
require 'inch_ci/grade_list_collection'

module InchCI
  module Worker
    module Project
      module Build
        class GenerateBadge
          def self.call(*args)
            new(*args)
          end

          def initialize(project, branch, code_objects)
            Badge.create(project, branch, grade_counts(code_objects))
          end

          private

          def grade_counts(code_objects)
            GradeListCollection.new(filter(code_objects)).map(&:count)
          end

          def filter(code_objects)
            code_objects.select do |object|
              object.priority >= Config::MIN_RELEVANT_PRIORITY
            end
          end
        end
      end
    end
  end
end
