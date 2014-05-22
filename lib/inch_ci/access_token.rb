module InchCI
  # Manages access tokens for GitHub et al.
  class AccessToken
    class << self
      # Returns an access token for the given +service+
      def [](service)
        all[service.to_s]
      end

      # @return [Hash] all access tokens
      def all
        @all ||= YAML.load( File.read( File.join("config", "access_tokens.yml") ) )
      end
    end
  end
end
