require 'yaml'
require 'inch_ci/worker/project/build/save_build_data'

module InchCI
  module Worker
    module Project
      module Build
        class HandleWorkerOutput
          def initialize(stdout, stderr, build = nil, save_service = SaveBuildData)
            data = handle_stdout(stdout)
            if data && result = data['build']
              save_service.call(build, result, stderr)
            else
              debug = {:stdout => stdout, :stderr => stderr}
              raise "Running worker ".color(:red) + build.inspect.color(:cyan) +  " failed:".color(:red) + " #{debug.inspect}"
            end
          end

          private

          # Returns the last part of the given +output+, where YAML
          # is defined.
          # @param output [String,nil]
          # @return [String,nil]
          def handle_stdout(output)
            yaml = output =~ /^(---\n\S+\:\n.+)/m && $1
            yaml && YAML.load(yaml)
          end
        end
      end
    end
  end
end
