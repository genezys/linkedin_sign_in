require 'linkedin-id-token'
require 'active_support/core_ext/module/delegation'

module LinkedinSignIn
  class Identity
    class ValidationError < StandardError; end

    def initialize(token)
      set_extracted_payload(token)
    end

    def user_id
      @payload["id"]
    end

    def first_name
      @payload["firstName"]
    end

    def last_name
      @payload["lastName"]
    end

    def email_address
      @payload["emailAddress"]
    end

    def avatar_url
      @payload["pictureUrl"]
    end

    def current_company_name
      positions = @payload.dig("positions", "values")
      current_position = positions.find { |position| position["isCurrent"] }
      current_position.dig("company", "name")
    end

    private
      def set_extracted_payload(token)
        uri = URI("https://api.linkedin.com/v1/people/~:(id,firstName,lastName,picture-url,email-address,positions)?format=json")
        request = Net::HTTP::Get.new uri
        request['Authorization'] = "Bearer #{token}"
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        case response
        when Net::HTTPSuccess
          @payload = JSON(response.body)
        else
          raise ValidationError, response.body
        end
      end
  end
end
