require 'spec_helper'

describe DomainNameProvider::Adapters::RestClient do

  let(:valid_config) {{:scheme => 'http', :host => 'www.example.com', :path => '/path'}}

  context "Initialization" do
    it "returns the configuration" do
      dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
      expect(dnarc.configuration).to eql valid_config
    end
  end

  context "#valid_configuration?" do
    it "returns true if configuration is valid" do
      dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
      expect(dnarc.valid_configuration?).to eql true
    end

    context "Invalid configuration" do
      it "returns false if empty" do
        dnarc = DomainNameProvider::Adapters::RestClient.new({})
        expect(dnarc.valid_configuration?).to eql false
      end

      it "returns false if scheme empty" do
        dnarc = DomainNameProvider::Adapters::RestClient.new({:host => 'example.com', :path => '/path'})
        expect(dnarc.valid_configuration?).to eql false
      end

      it "returns false if host empty" do
        dnarc = DomainNameProvider::Adapters::RestClient.new({:scheme => 'http', :path => '/path'})
        expect(dnarc.valid_configuration?).to eql false
      end

      it "returns false if path empty" do
        dnarc = DomainNameProvider::Adapters::RestClient.new({:scheme => 'https', :host => 'example.com'})
        expect(dnarc.valid_configuration?).to eql false
      end
    end
  end

  context "#setup_connection" do
    it "returns a connection" do
      dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
      dnarc.setup_connection

      expect(dnarc.connection.class).to eql Faraday::Connection
    end

    context "Additional options" do
      context "SSL verification" do
        it "return true by default" do
          dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
          dnarc.setup_connection

          expect(dnarc.connection.ssl.verify).to eql true
        end

        it "return false if options :verify_ssl is set to false" do
          options = {:options => {:verify_ssl => false}}

          dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config.merge(options))
          dnarc.setup_connection

          expect(dnarc.connection.ssl.verify).to eql false
        end
      end

      context "Basic authorization" do
        it "By default it should not use basic auth" do
          connection = double(Faraday::Connection).as_null_object
          allow(Faraday::Connection).to receive(:new) { connection }

          dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
          expect(connection).not_to receive(:basic_auth).with('test', 'secret')

          dnarc.setup_connection
        end

        it "Setup the connection request with basic auth" do
          options = {:options => {:basic_auth => { :user => 'test', :password => 'secret'}}}

          connection = double(Faraday::Connection).as_null_object
          allow(Faraday::Connection).to receive(:new) { connection }

          dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config.merge(options))
          expect(connection).to receive(:basic_auth).with('test', 'secret')

          dnarc.setup_connection
        end
      end
    end
  end

  context "#get" do
    it "makes a GET call to the correct path" do
      double_faraday = double(Faraday::Connection).as_null_object
      allow(Faraday::Connection).to receive(:new) { double_faraday }

      dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
      dnarc.setup_connection

      expect(double_faraday).to receive(:get).with("/path", {})
      dnarc.get('/path')
    end


    it "makes a GET call to the correct PATH with the provided params" do
      double_faraday = double(Faraday::Connection).as_null_object
      allow(Faraday::Connection).to receive(:new) { double_faraday }

      dnarc = DomainNameProvider::Adapters::RestClient.new(valid_config)
      dnarc.setup_connection

      expect(double_faraday).to receive(:get).with("/path", {:var => "test"})
      dnarc.get('/path', {:var => 'test'})
    end
  end
end
