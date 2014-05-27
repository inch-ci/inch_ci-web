require 'yaml'
require 'inch_ci/worker/project/build/save_build_data'

module InchCI
  module Worker
    module Project
      module Build
        class HandleWorkerOutput
          def initialize(stdout, stderr, build = nil, save_service = SaveBuildData)
            data = YAML.load(stdout)
            if data && result = data['build']
              save_service.call(build, result)
            else
              debug = {:stdout => stdout, :stderr => stderr}
              raise "Running worker ".color(:red) + build.inspect.color(:cyan) +  " failed:".color(:red) + " #{debug.inspect}"
            end
          end
        end
      end
    end
  end
end
