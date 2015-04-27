require 'net/http'
require 'uri'

module InchCI
  module Gossip
    def self.load_config
      filename = File.join(Rails.root, "config", "gossip.yml")
      if File.exist?(filename)
        YAML.load(File.read(filename))
      else
        {}
      end
    end

    GOSSIP_HOST = load_config['server']
    GOSSIP_ACTIVE = GOSSIP_HOST.to_s != ""
    GOSSIP_URL = "http://#{GOSSIP_HOST}/projects/:event_name"

    class << self
      def new_build(build, project, branch)
        return if inactive?
        post('new_build', build, project, branch)
      end

      def update_build(build, project, branch)
        return if inactive?
        post('update_build', build, project, branch)
      end

      private

      def inactive?
        !GOSSIP_ACTIVE
      end

      def post(event_name, build, project, branch)
        Net::HTTP.post_form url(event_name), payload(build, project, branch)
      end

      def url(event_name)
        URI(GOSSIP_URL.gsub(':event_name', event_name))
      end

      def payload(build, project, branch)
        {
          "build_number" => build.number,
          "build_id" => build.id,
          "build_status" => build.status,
          "build_url" => "/builds/#{build.id}.json",
          "build_started_at" => build.started_at,
          "project_uid" => project.uid,
          "branch_name" => branch.name
        }
      end
    end
  end
end
