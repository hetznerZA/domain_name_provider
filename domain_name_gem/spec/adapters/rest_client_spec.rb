require 'spec_helper'
require 'webmock/rspec'

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
          valid_configuration = { :uri => "http://www.example.com/domain?domain_name=test.com" }
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
          invalid_uri_configuration = { :uri => "www.example.com/domain?domain_name=test.com" }
          rest_client = DomainNameGem::Adapters::RestClient.new(invalid_uri_configuration)

          expect(rest_client.valid_configuration?).to eql false
        end
      end
    end
  end

  context "#servers_domain_hosted_on" do
    it "return a list of servers the given domain is hosted on" do
      stub_request(:get, "http://www.example.com/domain?domain_name=test.com").to_return(:status => 200, :body => { :hostnames => ["server.example.com"] }.to_json, :headers => {})

      valid_configuration = { :uri => "http://www.example.com/domain?domain_name=test.com" }
      rest_client = DomainNameGem::Adapters::RestClient.new(valid_configuration)

      expect(rest_client.servers_domain_hosted_on('testdomain.co.za')).to eql ['server.example.com']
    end

    it "return a empty list if no results is found for a given domain" do
      stub_request(:get, "http://www.example.com/domain?domain_name=test.com").to_return(:status => 200, :body => { :hostnames => [] }.to_json, :headers => {})

      valid_configuration = { :uri => "http://www.example.com/domain?domain_name=test.com" }
      rest_client = DomainNameGem::Adapters::RestClient.new(valid_configuration)

      expect(rest_client.servers_domain_hosted_on('testdomain.co.za')).to eql []
    end
  end
end
