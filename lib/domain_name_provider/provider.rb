module DomainNameProvider
  class Provider
    attr_reader :adapter, :status

    def initialize(configuration)
      #TODO: adapter class name, should we pass in string and load class?
      @status = 'fail'

      if valid_configuration?(configuration)
        @adapter = configuration[:adapter][:class_name].new(configuration[:adapter][:configuration])

        if @adapter.valid_configuration?
          @status = 'success'
        end
      end
    end

    def servers_domain_hosted_on(domain_name)
      @adapter.servers_domain_hosted_on(domain_name)
    end

    private
    def valid_configuration?(configuration)
      return false if configuration[:adapter].nil?
      return false if configuration[:adapter][:class_name].nil?
      true
    end
  end
end
