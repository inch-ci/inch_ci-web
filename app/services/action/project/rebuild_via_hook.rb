require 'inch_ci/action'

module Action
  module Project
    class RebuildViaHook
      include InchCI::Action

      exposes :result

      def initialize(params)
        if params[:payload]
          payload = JSON[params[:payload]]
          project = InchCI::Store::FindProject.call(project_uid(payload))
          enqueue_build(project, branch_name(payload))
          @result = "OK"
        else
          @result = "ERROR"
        end
      end

      private

      def enqueue_build(project, branch_name)
        build = InchCI::Worker::Project::Build.enqueue(project.repo_url, branch_name)
      end

      def branch_name(payload)
        payload['ref'] =~ /^refs\/heads\/(.+)$/ && $1
      end

      def project_uid(payload)
        web_url = payload['repository'] && payload['repository']['url']
        info = InchCI::RepoURL.new(web_url+'.git')
        info.project_uid
      end
    end
  end
end
