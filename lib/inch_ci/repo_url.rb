module InchCI
  class RepoURL
    attr_reader :service, :url

    def initialize(url)
      @url = url
      @service = Repomen::Repo::Service.for(url)
    end

    def project_uid
      return if service.nil?
      "#{service.name}:#{service.user_name}/#{service.repo_name}"
    end
  end
end
