require 'inch_ci/worker/project/build/handle_worker_output'
require 'open3'

module InchCI
  module Worker
    module Project
      module Build
        def self.enqueue(url, branch_name = 'master', revision_uid = nil, trigger = 'manual')
          branch = Store::EnsureProjectAndBranch.call(url, branch_name)
          build = Store::CreateBuild.call(branch, trigger)
          ShellInvocation.perform_async(url, branch_name, revision_uid, trigger, build.id)
          build
        end

        # The ShellInvocation class spawns another shell in which the given
        # repo is analysed. The executed script then returns a YAML formatted
        # string which contains the "build data".
        #
        # Note: A new shell is spawned so that the resulting process has its
        #   own cwd and Dir.chdir has not to be synchronized across worker
        #   threads.
        #
        class ShellInvocation
          include Sidekiq::Worker

          BIN = "bundle exec inch_ci-worker build"

          def perform(url, branch_name = 'master', revision_uid = nil, trigger = 'manual', build_id = nil)
            build = ensure_running_build(url, branch_name, trigger, build_id)
            stdout_str, stderr_str, status = Open3.capture3("#{BIN} #{url.inspect} #{branch_name} #{revision_uid}")
            HandleWorkerOutput.new(stdout_str, stderr_str, build)
          end

          private

          def create_preliminary_build(url, branch_name, trigger)
            branch = Store::EnsureProjectAndBranch.call(url, branch_name)
            Store::CreateBuild.call(branch, trigger)
          end

          def ensure_running_build(url, branch_name, trigger, build_id)
            if build_id
              build = Store::FindBuild.call(build_id)
              Store::UpdateBuildStatus.call(build, 'running', Time.now)
              build
            else
              create_preliminary_build(url, branch_name, trigger)
            end
          end
        end
      end
    end
  end
end
