require 'json'

module DomainNameProvider
  module Adapters
    class Http < RestClient
      def servers_domain_hosted_on(domain_name)
        setup_connection
        response = get(@configuration[:path], {:domain_name => domain_name})
        validate_response(response.status, response.body)
      end

      private
      def validate_response(status, body)
        raise DomainNameProvider::Adapters::HttpError.new('Bad Request') if status == 400
        raise DomainNameProvider::Adapters::HttpError.new('Response missing keyword :hostnames') if status == 200 && missing_keyword?(body)

        return JSON.parse(body)["hostnames"] if status == 200
      end

      def missing_keyword?(data)
        data = JSON.parse(data)
        if data.key?("hostnames")
          return false
        end
        true
      end
    end

    class HttpError < StandardError
    end
  end
end
