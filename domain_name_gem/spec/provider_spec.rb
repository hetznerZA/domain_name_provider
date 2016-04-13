require 'spec_helper'

describe DomainNameGem::Provider do
  context "#adapter" do
    context "Given no adapter is provided" do
      it "should return a default adapter" do
        dnp = DomainNameGem::Provider.new
        expect(dnp.adapter).to eql 'default_adapter'
      end
    end

    context "Changing the adapter" do
      it "should override default adapter" do
        dnp = DomainNameGem::Provider.new
        dnp.adapter=('my_new_shiny_adapter')

        expect(dnp.adapter).to eql 'my_new_shiny_adapter'
      end
    end
  end

  context "#servers_domain_hosted_on?" do
    it "should return a list of servers for a given domain name" do
      dnp = DomainNameGem::Provider.new
      dnp.adapter=(FakeAdapter)
      expect(dnp.servers_domain_hosted_on?('example.com')).to eql ['www10.tst1.host-h.net']
    end
  end
end

module FakeAdapter
  def self.servers_domain_hosted_on?(domain_name)
    ['www10.tst1.host-h.net']
  end
end
