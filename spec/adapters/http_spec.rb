require 'spec_helper'

describe DomainNameProvider::Adapters::Http do

  let(:valid_config) {{:scheme => 'http', :host => 'www.example.com', :path => '/path'}}
  let(:double_response) { double('Response', :status => 200, :body => {:hostnames => ['server.example.com']}.to_json)  }

  context "#servers_domain_hosted_on" do
    context "Given a domain name which is hosted on a server" do
      it "creates a connection" do
        http = DomainNameProvider::Adapters::Http.new(valid_config)
        allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response)

        http.servers_domain_hosted_on('example.com')

        expect(http.connection.class).to eql Faraday::Connection
      end

      it "makes a HTTP get call with the provided path and parameters" do
        http = DomainNameProvider::Adapters::Http.new(valid_config)

        expect(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response)
        http.servers_domain_hosted_on('example.com')
      end

      it "returns a list of hostnames" do
        http = DomainNameProvider::Adapters::Http.new(valid_config)

        allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response)
        expect(http.servers_domain_hosted_on('example.com')).to eql ["server.example.com"]
      end
    end

    it "returns an empty list if the given domain name is not hosted on any servers" do
      double_response_no_results = double('Response', :status => 200, :body => {:hostnames => []}.to_json)
      http = DomainNameProvider::Adapters::Http.new(valid_config)

      allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response_no_results)
      expect(http.servers_domain_hosted_on('example.com')).to eql []
    end

    context "Raises an Error if something goes wrong" do
      it "raise JSON::ParserError, if the response is not valid JSON" do
        double_response_no_json = double('Response', :status => 200, :body => "")

        http = DomainNameProvider::Adapters::Http.new(valid_config)
        allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response_no_json)

        expect { http.servers_domain_hosted_on('example.com') } .to raise_error(JSON::ParserError)
      end

      it "Raises DomainNameProvider::Adapters::HttpError 'Bad Request', if the response status is 400 Bad Request" do
        double_response_bad_request = double('Response', :status => 400, :body => "")

        http = DomainNameProvider::Adapters::Http.new(valid_config)
        allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response_bad_request)

        expect { http.servers_domain_hosted_on('example.com') } .to raise_error(DomainNameProvider::Adapters::HttpError, 'Bad Request')
      end

      it "Raises DomainNameProvider::Adapters::HttpError 'Response missing keyword :hostnames', if the response status is 200 and the body is empty JSON" do
        double_response_empty = double('Response', :status => 200, :body => {}.to_json)
        http = DomainNameProvider::Adapters::Http.new(valid_config)

        allow(http).to receive(:get).with('/path', {:domain_name => 'example.com'}).and_return(double_response_empty)
        expect { http.servers_domain_hosted_on('example.com') } .to raise_error(DomainNameProvider::Adapters::HttpError, 'Response missing keyword :hostnames')
      end
    end
  end
end

