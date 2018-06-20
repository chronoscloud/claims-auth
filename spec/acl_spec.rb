require 'spec_helper'
require 'claims_auth/acl'

describe ClaimsAuth::ACL do
  let(:configuration_path) { 'spec/config/authorizer_acl.yml' }

  describe "attribute accessors" do
    it "assigns acl" do
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

    context "when using valid parameters" do
      context "when http_method and resource_path is in config" do
        it "initializes a new ACLRecord" do
          expect(ClaimsAuth::ACLRecord).to receive(:new)

          acl.find_match("POST", "/users")
        end

        it "returns an ACLRecord" do
          expect(acl.find_match("POST", "/users")).to be_an_instance_of(ClaimsAuth::ACLRecord)
        end

        it "finds the record that matches the path pattern" do
          expect(acl.find_match("GET", "/users/2")).to_not be_nil
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
          expect(acl.find_match("GET", "/users////")).to be_nil
          expect(acl.find_match("GET", "/user/1/1/1/")).to be_nil
        end
      end
    end

    context "when using null parameters" do
      context "when http_method is null" do
        it "returns nil" do
          expect(acl.find_match(nil, "/test")).to be_nil
        end
      end

      context "when resource_path is null" do
        it "returns nil" do
          expect(acl.find_match("GET", "nil")).to be_nil
        end
      end
    end
  end
end

describe ClaimsAuth::ACLRecord do
  describe "attribute accessors" do
    let(:acl_record) { ClaimsAuth::ACLRecord.new("create_users", {"method"=>"POST", "path"=>"/users", "permissions"=>["USERS::CREATE"]}) }

    it "assigns name" do
      expect(acl_record.name).to eql("create_users")
    end

    it "assigns options" do
      expect(acl_record.options).to eql({"method"=>"POST", "path"=>"/users", "permissions"=>["USERS::CREATE"]})
    end
  end
end