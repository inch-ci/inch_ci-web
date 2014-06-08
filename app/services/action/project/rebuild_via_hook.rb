require 'inch_ci/action'

module Action
  module Project
    class RebuildViaHook
      include InchCI::Action
      include Action::EnsureProjectAndBranch

      TRIGGER = 'hook'

      exposes :result

      def initialize(params)
        if params[:payload]
          process_payload JSON[params[:payload]]
        elsif params[:ref]
          process_payload params
        else
          @result = "ERROR"
        end
      end

      private

      def enqueue_build(project, branch_name)
        build = InchCI::Worker::Project::Build.enqueue(project.repo_url, branch_name, nil, TRIGGER)
      end

      def branch_name(payload)
        payload['ref'] =~ /^refs\/heads\/(.+)$/ && $1
      end

      def process_payload(payload)
        branch = ensure_project_and_branch(project_url(payload), branch_name(payload))
        enqueue_build(branch.project, branch.name)
        @result = "OK"
      end

      def project_url(payload)
        if web_url = payload['repository'] && payload['repository']['url']
          "#{web_url}.git"
        end
      end
    end
  end
end
