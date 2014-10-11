require 'inch_ci/access_token'

module InchCI
  module Worker
    module Project
      class UpdateInfo

        # Retrieves project specific information via the GitHub API.
        class GitHubInfo
          def self.client
            @client ||= Octokit::Client.new :access_token => AccessToken[:github]
          end

          # @param nwo [String] name with owner (e.g. "rrrene/inch")
          def initialize(nwo)
            @nwo = nwo
            @repo = self.class.client.repository(nwo)
          end

          def branches
            list = self.class.client.branches(@nwo)
            list.map { |branch| branch[:name] }
          end

          def default_branch
            @repo[:default_branch]
          end

          def homepage_url
            @repo[:homepage]
          end

          def language
            @repo[:language]
          end

          def name
            @repo[:full_name]
          end

          def description
            @repo[:description]
          end

          def source_code_url
            @repo[:html_url]
          end

          def documentation_url
            if language.to_s.downcase == "ruby"
              "http://rubydoc.info/github/#{@nwo}/master/frames"
            end
          end
        end
      end
    end
  end
end
