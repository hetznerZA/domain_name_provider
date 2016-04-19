require 'spec_helper'
describe DomainNameGem::Adapters::RestClient do
  context "Initialization" do
    it "remember configuration" do
      configuration = { :uri => 'http://example.com/folder/file' }
      rest_client = DomainNameGem::Adapters::RestClient.new(configuration)

      expect(rest_client.configuration).to eql configuration
    end

    context "validate configuration" do
      context "return true" do
        it "returns true if the configuration is valid" do
          valid_configuration = { :uri => "http://www.mocky.io/v2/5714c4280f0000ef18490542?domain_name='testdomain.co.za'" }
          rest_client = DomainNameGem::Adapters::RestClient.new(valid_configuration)

          expect(rest_client.valid_configuration?).to eql true
        end
      end

      context "return false" do
        it "if configuration is empty" do
          rest_client = DomainNameGem::Adapters::RestClient.new({})
          expect(rest_client.valid_configuration?).to eql false
        end

        it "if configuration is missing a uri" do
          invalid_configuration = { :port => 80 }
          rest_client = DomainNameGem::Adapters::RestClient.new(invalid_configuration)

          expect(rest_client.valid_configuration?).to eql false
        end

        it "if the uri is not valid" do
          invalid_uri_configuration = { :uri => "www.mocky.io/v2/5714c4280f0000ef18490542" }
          rest_client = DomainNameGem::Adapters::RestClient.new(invalid_uri_configuration)

          expect(rest_client.valid_configuration?).to eql false
        end
      end
    end
  end

  context "#servers_domain_hosted_on" do
    it "return a list of servers the given domain is hosted on" do
      valid_configuration = { :uri => "http://www.mocky.io/v2/5714c4280f0000ef18490542?domain_name='testdomain.co.za'" }
      rest_client = DomainNameGem::Adapters::RestClient.new(valid_configuration)

      expect(rest_client.servers_domain_hosted_on('testdomain.co.za')).to eql ['server.example.com']
    end

    it "return a empty list if no results is found for a given domain" do
      empty_host_configuration = { :uri => "http://www.mocky.io/v2/5714c6d10f00005319490549?domain_name='testdomain.co.za'" }
      rest_client = DomainNameGem::Adapters::RestClient.new(empty_host_configuration)

      expect(rest_client.servers_domain_hosted_on('testdomain.co.za')).to eql []
    end
  end
end
