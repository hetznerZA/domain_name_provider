require 'spec_helper'

describe DomainNameProvider::Provider do
  context "Initialization" do
    context "configuration" do
      context "Given valid configuration" do
        it "return success status" do
          valid_configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { :user => 'test_user' } } }

          dnp = DomainNameProvider::Provider.new(valid_configuration)
          expect(dnp.status).to eql 'success'
        end
      end

      context "Given invalid configuration" do
        it "return an fail status" do
          invalid_configuration = { :adapter => nil }

          dnp = DomainNameProvider::Provider.new(invalid_configuration)
          expect(dnp.status).to eql 'fail'
        end
      end
    end

    context "Adapter initialization" do
      context "Given an valid adapter class and configuration" do
        it "return the correct adapter class name" do
          configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { :user => 'test' } } }
          dnp = DomainNameProvider::Provider.new(configuration)
          expect(dnp.adapter.class).to eql FakeAdapter
        end

        it "return an success status" do
          configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { :user => 'test' } } }
          dnp = DomainNameProvider::Provider.new(configuration)
          expect(dnp.status).to eql 'success'
        end
      end

      context "Given the adapter class doesn't exist" do
        it "return something" do
          pending
          configuration = { :adapter => { :class_name => 'Adapter', :configuration => { } } }
          dnp = DomainNameProvider::Provider.new(configuration)
          expect(dnp.status).to eql 'fail'
        end
      end

      context "Given invalid adapter configuration" do
        it "return an fail status" do
          configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { } } }
          dnp = DomainNameProvider::Provider.new(configuration)
          expect(dnp.status).to eql 'fail'
        end
      end
    end
  end

  context "#servers_domain_hosted_on" do
    it "return a list of servers" do
      configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { :user => 'test' } } }
      dnp = DomainNameProvider::Provider.new(configuration)

      expect(dnp.servers_domain_hosted_on('setup_on_one_server.co.za')).to eql ['server100.example.com']
    end

    it "return an empty list if no results are found" do
      configuration = { :adapter => { :class_name => 'FakeAdapter', :configuration => { :user => 'test' } } }
      dnp = DomainNameProvider::Provider.new(configuration)

      expect(dnp.servers_domain_hosted_on('not_setup_on_any_servers.co.za')).to be_empty
    end
  end
end

class FakeAdapter
  def initialize(configuration)
    @configuration = configuration
  end

  def valid_configuration?
    return false if @configuration[:user].nil?
    true
  end

  def servers_domain_hosted_on(domain_name)
    return ['server100.example.com'] if domain_name == 'setup_on_one_server.co.za'
    return [] if domain_name == 'not_setup_on_any_servers.co.za'
  end
end
