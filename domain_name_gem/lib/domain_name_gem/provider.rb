module DomainNameGem
  class Provider
    attr_reader :configuration, :adapter

    def initialize(configuration)
      @adapter = configuration[:adapter].new(configuration)
    end

    def servers_domain_hosted_on?(domain_name)
      @adapter.servers_domain_hosted_on?(domain_name)
    end
  end
end
