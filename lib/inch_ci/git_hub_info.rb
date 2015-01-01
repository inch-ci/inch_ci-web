require 'open-uri'
require 'inch_ci/access_token'

module InchCI
  # Retrieves project specific information via the GitHub API.
  module GitHubInfo
    def self.client
      @client ||= begin
        options = if AccessToken[:github_client_id] && AccessToken[:github_secret]
          {:client_id => AccessToken[:github_client_id], :client_secret => AccessToken[:github_secret]}
        else
          {:access_token => AccessToken[:github]}
        end
        Octokit::Client.new(options.merge(:per_page => 100))
      end
    end

    def self.repo(nwo)
      Repo.new(client.repository(nwo))
    end

    def self.user(user_name)
      User.new(user_name)
    end

    class User
      attr_reader :repos

      def initialize(user_name)
        @client = GitHubInfo.client
        @user_name = user_name
        @repos = []
        retrieve_repos
      end

      private

      def retrieve_repos(page = 1)
        @repos.concat @client.repos(@user_name, :page => page)
        retrieve_repos(page + 1) if @client.last_response.rels[:next]
      end
    end

    class Repo
      # @param nwo [String] name with owner (e.g. "rrrene/inch")
      def initialize(repo)
        @repo = repo
        @nwo = repo.full_name
      end

      def branches
        list = GitHubInfo.client.branches(@nwo)
        list.map { |branch| branch[:name] }
      end

      def default_branch
        @repo[:default_branch]
      end

      def fork?
        @repo[:fork]
      end

      def homepage_url
        @repo[:homepage]
      end

      def hooks
        @client.hooks(@nwo)
      end

      def language
        @repo[:language]
      end

      def languages
        @languages ||= [] # retrieve_languages
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

      # Used to check if the project is already known.
      def url
        RepoURL.new(@repo[:html_url]).repo_url
      end

      private

      def retrieve_languages
        io = open(@repo.languages_url)
        hash = JSON.load(io)
        hash.keys
      rescue OpenURI::HTTPError
        p :ERROR => @repo.languages_url
        []
      end
    end
  end
end
