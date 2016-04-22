require 'json'

module DomainNameProvider
  module Adapters
    class Http < RestClient
      def servers_domain_hosted_on(domain_name)
        setup_connection
        #TODO: query should come from config
        #{ :query => { :name => 'piet', :surname => ''}}
        #params = @configuration[query]

        response = get(@configuration[:path], {:domain_name => domain_name})

        JSON.parse(response.body)["hostnames"]
      end
    end
  end
end
