require 'inch_ci/diff'

module InchCI
  module Worker
    module Project
      module Build
        class CalculateDiff
          attr_reader :diff

          def self.call(*args)
            new(*args).diff
          end

          def initialize(revision1, revision2)
            objects1 = if revision1
                Store::FindCodeObjects.call(revision1)
              else
                []
              end
            objects2 = Store::FindCodeObjects.call(revision2)
            @diff = Diff.new(objects1, objects2)
          end
        end
      end
    end
  end
end
