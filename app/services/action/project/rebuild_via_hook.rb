require 'inch_ci/action'

module Action
  module Project
    class RebuildViaHook
      include InchCI::Action

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
        project = InchCI::Store::FindProject.call(project_uid(payload))
        enqueue_build(project, branch_name(payload))
        @result = "OK"
      end

      def project_uid(payload)
        if web_url = payload['repository'] && payload['repository']['url']
          info = InchCI::RepoURL.new(web_url)
          info.project_uid
        end
      end
    end
  end
end
