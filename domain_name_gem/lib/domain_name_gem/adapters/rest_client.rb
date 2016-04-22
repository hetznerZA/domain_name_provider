require 'faraday'
require 'json'

module DomainNameGem
  module Adapters
    class RestClient
      attr_reader :configuration, :connection

      def initialize(configuration)
        @configuration = configuration
      end

      def valid_configuration?
        return true if validate_configuration(@configuration)
        false
      end

      def validate_configuration(configuration)
        #TODO: Improve validation: verify scheme == http/s and if host or ip is valid and path valid has /
        return true if configuration[:scheme] && configuration[:host] && configuration[:path]
      end

      def setup_connection
        parameters = { :url => "#{@configuration[:scheme]}://#{@configuration[:host]}", :ssl => { :verify => true } }
        parameters[:ssl][:verify] = false if @configuration[:options] && @configuration[:options][:verify_ssl] == false

        @connection = Faraday.new(parameters).tap do |conn|
          #TODO: Cleanup basic_auth if
          conn.basic_auth @configuration[:options][:basic_auth][:user], @configuration[:options][:basic_auth][:password] if @configuration[:options] && @configuration[:options][:basic_auth] && @configuration[:options][:basic_auth][:user] && @configuration[:options][:basic_auth][:password]
          conn.adapter  :net_http
        end
      end

      def get(path, params = {})
        @connection.get(path, params)
      end
    end
  end
end
