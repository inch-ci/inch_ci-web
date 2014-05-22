module InchCI
  module Worker
    module Project
      module BuildTags
        def self.enqueue(url, branch_name = "master")
          branch = Store::EnsureProjectAndBranch.call(url, branch_name)
          ShellInvocation.perform_async(url, branch_name)
        end

        # The ShellInvocation class spawns another shell in which the given
        # repo is analysed. The executed script then returns a YAML formatted
        # string which contains the list of tags.
        #
        # Note: A new shell is spawned so that the resulting process has its
        #   own cwd and Dir.chdir has not to be synchronized across worker
        #   threads.
        #
        class ShellInvocation
          include Sidekiq::Worker

          BIN = "bundle exec inch_ci-worker list-tags"

          def perform(url, branch_name = "master")
            output = `#{BIN} #{url.inspect} #{branch_name}`
            HandleWorkerOutput.new(url, branch_name, output)
          end
        end

        class HandleWorkerOutput
          def initialize(url, branch_name, output)
            data = YAML.load(output)
            if data && tags = data['tags']
              tags.each do |tag|
                Build.enqueue(url, branch_name, tag, 'tag_build')
              end
            else
              raise "Running worker ".color(:red) + url.color(:cyan) +  " failed:".color(:red) + " #{output.inspect}"
            end
          end
        end
      end
    end
  end
end
