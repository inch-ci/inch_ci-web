module InchCI
  class ProjectUID
    attr_reader :service, :user_name, :repo_name

    def initialize(params_or_uid)
      if params_or_uid.is_a?(Hash)
        @service = params_or_uid[:service]
        @user_name = params_or_uid[:user]
        @repo_name = params_or_uid[:repo]
      else
        service_and_nwo = params_or_uid.split(':')
        @service = service_and_nwo.first
        nwo = service_and_nwo.last.split('/')
        if nwo.size == 2
          @user_name = nwo.first
          @repo_name = nwo.last
        end
      end
    end

    def blank?
      service.to_s.empty? || user_name.to_s.empty? || repo_name.to_s.empty?
    end

    def project_uid
      return if blank?
      "#{service}:#{user_name}/#{repo_name}"
    end

    def repo_url
      return if blank?
      if service == 'github'
        "https://github.com/#{user_name}/#{repo_name}.git"
      else
        raise "Unknown service: #{service}"
      end
    end
  end
end
