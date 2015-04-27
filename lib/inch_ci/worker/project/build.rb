require 'inch_ci/worker/project/build/handle_worker_output'
require 'inch_ci/gossip'
require 'open3'

module InchCI
  module Worker
    module Project
      # The Build worker is responsible for "building" projects,
      # i.e. cloning and analysing repos, by utilizing a gem called
      # "inch_ci-worker".
      module Build
        # @param url [String]
        # @param branch_name [String]
        # @param revision_uid [String]
        # @param trigger [String]
        # @return [Build]
        def self.enqueue(url, branch_name = 'master', revision_uid = nil, trigger = 'manual')
          branch = Store::EnsureProjectAndBranch.call(url, branch_name)
          project = branch.project
          build = Store::CreateBuild.call(branch, trigger)
          Gossip.new_build(build, build.project, build.branch)
          ShellInvocation.perform_async(url, branch_name, revision_uid, trigger, build.id, project.language)
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

          # @api private
          def perform(url, branch_name = 'master', revision_uid = nil, trigger = 'manual', build_id = nil, language = nil)
            build = ensure_running_build(url, branch_name, trigger, build_id)
            cmd = "#{BIN} #{url.inspect} #{branch_name} #{revision_uid}"
            cmd << " --language=#{language}" if language
            stdout_str, stderr_str, status = Open3.capture3(cmd)
            HandleWorkerOutput.new(stdout_str, stderr_str, build)
            Gossip.update_build(build, build.project, build.branch)
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
              Gossip.update_build(build, build.project, build.branch)
              build
            else
              build = create_preliminary_build(url, branch_name, trigger)
              Gossip.new_build(build, build.project, build.branch)
              build
            end
          end
        end
      end
    end
  end
end
