module DomainNameGem
  class Provider
    def adapter
      return @adapter if @adapter
      @adapter = 'default_adapter'
    end

    def adapter=(adapter_class)
      @adapter = adapter_class
    end

    def servers_domain_hosted_on?(domain_name)
      self.adapter.servers_domain_hosted_on?(domain_name)
    end
  end
end
