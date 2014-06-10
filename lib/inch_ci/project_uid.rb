module InchCI
  class ProjectUID
    attr_reader :service, :user_name, :repo_name

    def initialize(params)
      @service = params[:service]
      @user_name = params[:user]
      @repo_name = params[:repo]
    end

    def blank?
      !(service && user_name && repo_name)
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
