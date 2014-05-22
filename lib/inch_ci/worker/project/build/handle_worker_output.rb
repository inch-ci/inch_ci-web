require 'yaml'
require_relative 'save_build_data'

module InchCI
  module Worker
    module Project
      module Build
        class HandleWorkerOutput
          def initialize(output, build = nil, save_service = SaveBuildData)
            data = YAML.load(output)
            if data && result = data['build']
              save_service.call(build, result)
            else
              raise "Running worker ".color(:red) + build.inspect.color(:cyan) +  " failed:".color(:red) + " #{output.inspect}"
            end
          end
        end
      end
    end
  end
end
