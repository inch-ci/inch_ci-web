module InchCI
  class RepoURL
    attr_reader :service, :url

    def initialize(url)
      @url = url.to_s.gsub(/(\/)\Z/, '')
      [@url, @url + '.git'].each do |_url|
        @service ||= Repomen::Repo::Service.for(_url)
      end
    end

    def project_uid
      return if service.nil?
      "#{service.name}:#{service.user_name}/#{service.repo_name}"
    end

    def repo_url
      return if service.nil?
      if service.name.to_s == 'github'
        "https://github.com/#{service.user_name}/#{service.repo_name}.git"
      else
        url
      end
    end
  end
end
