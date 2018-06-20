require 'spec_helper'
require 'claims_auth/acl'

describe ClaimsAuth::ACL do
  let(:configuration_path) { 'spec/config/authorizer_acl.yml' }

  describe "attribute accessors" do
    it "should have acl" do
      acl_object = ClaimsAuth::ACL.load_from_configuration(configuration_path)

      expect(acl_object.acl).to_not be_nil
    end
  end

  describe "#load_from_configuration" do
    context "when configuration_path is specified" do
      it "loads a YAML file from the configuration_path" do
        expect(YAML).to receive(:load_file).with('spec/config/authorizer_acl.yml')

        ClaimsAuth::ACL.load_from_configuration(configuration_path)
      end
    end

    context "when no configuration_path is specified" do
      it "loads a YAML file using a default path" do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file(configuration_path))
        expect(YAML).to receive(:load_file).with('config/authorizer_acl.yml')

        ClaimsAuth::ACL.load_from_configuration
      end
    end

    it "initializes a new ACL" do
      expect(ClaimsAuth::ACL).to receive(:new)

      ClaimsAuth::ACL.load_from_configuration(configuration_path)
    end

    it "returns an ACL object" do
      expect(ClaimsAuth::ACL.load_from_configuration(configuration_path)).to be_an_instance_of(ClaimsAuth::ACL)
    end
  end

  describe "#find_match" do
    let(:acl) { ClaimsAuth::ACL.load_from_configuration(configuration_path) }

    context "when http_method and resource_path is in config" do
      it "initializes a new ACLRecord" do
        expect(ClaimsAuth::ACLRecord).to receive(:new)

        acl.find_match("POST", "/users")
      end

      it "returns an ACLRecord" do
        expect(acl.find_match("POST", "/users")).to be_an_instance_of(ClaimsAuth::ACLRecord)
      end
    end

    context "when http_method is not in config" do
      it "returns nil" do
        expect(acl.find_match("DELETE", "/users")).to be_nil
      end
    end

    context "when resource_path is not in config" do
      it "returns nil" do
        expect(acl.find_match("GET", "/test")).to be_nil
      end
    end
  end
end