require 'spec_helper'
require 'webmock/rspec'

describe DomainNameProvider::Provider do
  context "Given valid minimal configuration" do
    context "and the given a domain name is hosted on a server/s" do
      it "returns a list of servers" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => {:hostnames => ['server1.example.com']}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect(dnp.servers_domain_hosted_on('exmaple.com')).to eql ['server1.example.com']
      end
    end

    context "and the given domain name not hosted on a server" do
      it "returns an empty list" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => {:hostnames => []}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect(dnp.servers_domain_hosted_on('exmaple.com')).to eql []
      end
    end

    context "and the path is incorrect" do
      it "raise a DomainNameProvider::Adapters::HttpError 'Bad Request' error" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/pathdoesnotexist'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/pathdoesnotexist?domain_name=exmaple.com").to_return(:status => 400, :body => {:hostnames => []}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect { dnp.servers_domain_hosted_on('exmaple.com') }.to raise_error(DomainNameProvider::Adapters::HttpError, "Bad Request")
      end
    end

    context "and the response is not JSON" do
      it "raise JSON::ParserError" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => "{:hostnames => []}", :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect { dnp.servers_domain_hosted_on('exmaple.com') }.to raise_error(JSON::ParserError)
      end
    end

    context "and the response is missing a keyword" do
      it "raise a DomainNameProvider::Adapters::HttpError 'Missing keyword :hostnames' error" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => {:names => []}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect { dnp.servers_domain_hosted_on('exmaple.com') }.to raise_error(DomainNameProvider::Adapters::HttpError, "Response missing keyword :hostnames")
      end
    end
  end

  context "Given invalid" do
    context "provider configuration" do
      it "returns a failure status" do
        adapter_config = {:scheme => 'http', :host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => {:names => []}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect(dnp.status).to eql 'failure'
        #TODO: Should not be do the code below if fail
        #expect { dnp.servers_domain_hosted_on('exmaple.com') }.to raise_error(DomainNameProvider::Adapters::HttpError, "Response missing keyword :hostnames")
      end
    end

    context "adapter configuration and valid provider configuration" do
      it "returns a failure status" do
        adapter_config = {:host => 'www.example.com', :path => '/path'}
        configuration = {:adapter => {:class_name => 'DomainNameProvider::Adapters::Http', :configuration => adapter_config}}
        stub_request(:get, "http://www.example.com/path?domain_name=exmaple.com").to_return(:status => 200, :body => {:names => []}.to_json, :headers => {})

        dnp = DomainNameProvider::Provider.new(configuration)
        expect(dnp.status).to eql 'failure'
        #TODO: Should not be do the code below if fail
        #expect { dnp.servers_domain_hosted_on('exmaple.com') }.to raise_error(DomainNameProvider::Adapters::HttpError, "Response missing keyword :hostnames")
      end
    end
  end
end
