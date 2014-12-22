require 'open-uri'
require 'inch_ci/access_token'

module InchCI
  # Retrieves project specific information via the GitHub API.
  class GitHubInfo
    def self.client
      @client ||= Octokit::Client.new :access_token => AccessToken[:github]
    end

    def self.from_nwo(nwo)
      new(nwo, client.repository(nwo))
    end

    # @param nwo [String] name with owner (e.g. "rrrene/inch")
    def initialize(nwo, repo)
      @nwo = nwo
      @repo = repo
    end

    def branches
      list = self.class.client.branches(@nwo)
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

    def language
      @repo[:language]
    end

    def languages
      @languages ||= retrieve_languages
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

    private

    def retrieve_languages
      io = open(@repo.languages_url)
      hash = JSON.load(io)
      hash.keys
    end
  end
end
