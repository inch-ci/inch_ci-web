module InchCI
  # Manages access tokens for GitHub et al.
  class AccessToken
    def initialize(path)
      @hash = load_yaml(path) || {}
    end

    def [](key)
      @hash[key.to_s]
    end

    private

    def load_yaml(path)
      YAML.load_file(path)
    rescue Errno::ENOENT
      nil
    end

    class << self
      # Returns an access token for the given +service+
      def [](service)
        all[service.to_s]
      end

      # @return [Hash] all access tokens
      def all
        @all ||= new(File.join("config", "access_tokens.yml"))
      end
    end
  end
end
