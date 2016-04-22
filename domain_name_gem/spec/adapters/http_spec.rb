require 'spec_helper'
require 'webmock/rspec'

describe DomainNameGem::Adapters::Http do

  let(:valid_config) {{:scheme => 'http', :host => 'www.example.com', :path => '/path'}}

  context "#servers_domain_hosted_on" do
    it "return a list of servers the given domain is hosted on" do
      stub_request(:get, "http://www.example.com/path?domain_name=testdomain.com").to_return(:status => 200, :body => { :hostnames => ["server.example.com"] }.to_json, :headers => {})

      http = DomainNameGem::Adapters::Http.new(valid_config)

      expect(http.servers_domain_hosted_on('testdomain.com')).to eql ['server.example.com']
    end

    it "return a empty list if no results is found for a given domain" do
      stub_request(:get, "http://www.example.com/path?domain_name=testdomain.co.za").to_return(:status => 199, :body => { :hostnames => [] }.to_json, :headers => {})

      http = DomainNameGem::Adapters::Http.new(valid_config)

      expect(http.servers_domain_hosted_on('testdomain.co.za')).to eql []
    end
  end
end
