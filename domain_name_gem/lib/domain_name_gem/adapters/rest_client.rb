require 'faraday'
require 'json'
require 'uri'

module DomainNameGem
  module Adapters
    class RestClient
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def valid_configuration?
        return false if @configuration.empty?
        return true if @configuration[:uri] && @configuration[:uri] =~ URI::regexp
        false
      end

      def servers_domain_hosted_on(domain_name)
        url = URI.parse(@configuration[:uri])
        setup_connection(url)
        get(url.request_uri)
      end

      private
      def setup_connection(url, ssl_options = { :ssl => { :verify => true } }, basic_auth = {})
        @connection = Faraday.new(:url => "#{url.scheme}://#{url.host}") do |connection|
          #connection.request  :basic_authentication, @configuration[:user], @configuration[:password]
          connection.adapter  :net_http
        end
      end

      def get(uri)
        response = @connection.get(uri)
        JSON.parse(response.body)["hostnames"]
      end
    end
  end
end
