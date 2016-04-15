require 'spec_helper'

describe DomainNameGem::Provider do


  context "When initialized" do
    context "Configure Adapter" do
      context "Changing the adapter" do
        it "override default adapter" do
          configuration = { :adapter => FakeAdapter }
          dnp = DomainNameGem::Provider.new(configuration)

          expect(dnp.adapter.class).to eql FakeAdapter
        end
      end

      context "Given no adapter is provided" do
        it "return a default adapter" do
          pending
        end
      end
    end
  end

  context "#servers_domain_hosted_on?" do
    it "return a list of servers" do
      configuration = { :adapter => FakeAdapter }
      dnp = DomainNameGem::Provider.new(configuration)

      expect(dnp.servers_domain_hosted_on?('setup_on_one_server.co.za')).to eql ['www10.tst1.host-h.net']
    end

    it "return an empty list if no results are found" do
      configuration = { :adapter => FakeAdapter }
      dnp = DomainNameGem::Provider.new(configuration)

      expect(dnp.servers_domain_hosted_on?('not_setup_on_any_servers.co.za')).to be_empty
    end
  end
end

class FakeAdapter
  def initialize(configuration)
    @configuration = configuration
  end

  def servers_domain_hosted_on?(domain_name)
    return ['www10.tst1.host-h.net'] if domain_name == 'setup_on_one_server.co.za'
    return [] if domain_name == 'not_setup_on_any_servers.co.za'
  end
end
