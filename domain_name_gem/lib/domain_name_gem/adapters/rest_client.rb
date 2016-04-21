require 'faraday'
require 'json'
require 'uri'

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
        #TODO: Improve validation: verify scheme == http/s and if host or ip is valid
        return true if configuration[:scheme] && configuration[:host]
      end

      def setup_connection(options = {})
        parameters = { :url => "#{@configuration[:scheme]}://#{@configuration[:host]}", :ssl => { :verify => true } }
        parameters[:ssl][:verify] = false if options[:verify_ssl] == false

        @connection = Faraday.new(parameters).tap do |conn|
          conn.basic_auth options[:basic_auth][:user], options[:basic_auth][:password] if options[:basic_auth] && options[:basic_auth][:user] && options[:basic_auth][:password]
          conn.adapter  :net_http
        end
      end

      def get(path, params = {})
        @connection.get(path, params)
      end
    end
  end
end
