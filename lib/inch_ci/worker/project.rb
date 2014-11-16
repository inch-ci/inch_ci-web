require 'inch_ci/worker/project/build'
require 'inch_ci/worker/project/build_json'
require 'inch_ci/worker/project/build_tags'
require 'inch_ci/worker/project/update_info'

module InchCI
  module Worker
    module Project
      EXTERNALLY_BUILD = ['elixir']

      # @return [Boolean]
      #   whether or not the given +language+ can be built locally on Inch CI
      def self.build_on_inch_ci?(language)
        !EXTERNALLY_BUILD.include?(language.to_s.downcase)
      end
    end
  end
end
