require 'spec_helper'
require 'rack'
describe ChronosAuthz::Authorizer do

  class AuthorizeAllRequestRule < ChronosAuthz::Rule
    def request_authorized?
      true
    end
  end

  class BlockAllRequestsRule < ChronosAuthz::Rule
    def request_authorized?
      false
    end
  end

  describe "Middleware configuration" do

    it "should raise an error if default_rule isn't configured" do
      env = mock_env("/")
      app = lambda{}
      expect{ rack_app(app).call(env) }.to raise_error(ChronosAuthz::Validations::ValidationError)
    end

    it "should use default_rule for authorization check when no :rule option was specified in the matched ACL record" do
      env = mock_env("/accounts/")
      app = lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
      default_rule_class = AuthorizeAllRequestRule
      expect_any_instance_of(default_rule_class).to receive(:request_authorized?)
      rack_app(app, :default_rule => default_rule_class, :strict_mode => false).call(env)
    end

    it "should use the matched ACL Record's :rule option if it is specified" do
      env = mock_env("/users", method: "POST")
      app = lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
      expect_any_instance_of(ChronosAuthz::Spec::Helpers::CustomRule).to receive(:request_authorized?)
      expect_any_instance_of(AuthorizeAllRequestRule).to_not receive(:request_authorized?)
      rack_app(app, :default_rule => AuthorizeAllRequestRule, :strict_mode => false).call(env)
    end

    it "should use the configured error_page if the request is unauthorized" do
      env = mock_env("/accounts/123", method: "PUT")
      app = lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
      error_page_path = 'spec/config/error_page.html'
      error_page_contents = File.read(error_page_path)
      result = rack_app(app, :default_rule => BlockAllRequestsRule, :error_page => error_page_path).call(env)
      expect(result.last.first).to eq(error_page_contents)
    end
  end
 
  describe "Authorization" do

    it "should fail with a 403 response if strict_mode configuration is set to true and no ACL Record was configured for the incoming request" do
      env = mock_env("/some_unknown_path")
      app = lambda{}
      result = rack_app(app, :default_rule => AuthorizeAllRequestRule, :strict_mode => true).call(env)
      expect(result.first).to eq(403)
    end

    it "should not fail with a 403 response if strict_mode configuration is not set to true and no ACL Record was configured for the incoming request" do
      env = mock_env("/")
      app = lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
      result = rack_app(app, :default_rule => AuthorizeAllRequestRule, :strict_mode => false).call(env)
      expect(result.first).to eq(200)
    end

    it "should fail with a 403 response if authorization check failed" do
      env = mock_env("/")
      app = lambda{}
      result = rack_app(app, :default_rule => BlockAllRequestsRule).call(env)
      expect(result.first).to eq(403)
    end

    it "should not fail with a 403 response if authorization check succeeded" do
      env = mock_env("/")
      app = lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
      result = rack_app(app, :default_rule => AuthorizeAllRequestRule).call(env)
      expect(result.first).to eq(200)
    end
  end

  def rack_app(app, options= {})
    options[:acl_yaml] ||= 'spec/config/authorizer_acl_test.yml'
    Rack::Builder.new do
      use ChronosAuthz::Authorizer, options
      run app
    end
  end

  def mock_env(path = "/", params = {})
    method = params.delete(:method) || "GET"
    env = { 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => "#{method}" }
    Rack::MockRequest.env_for("#{path}?#{Rack::Utils.build_query(params)}", env)
  end

end