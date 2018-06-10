module ClaimsAuth

  class Authorizer

    class << self
      attr_accessor :configuration, :acl, :rules
    end
    @rules = {}
    @configuration ||= ClaimsAuth::Configuration.new

    def initialize(app)
      @app  = app

      self.class.acl = ClaimsAuth::ACL.load_from_configuration

      yield self.class.configuration if block_given?

      self.class.configuration.validate!
    end

    def call(env)
      claims = self.class.configuration.retrieve_claims_proc.call(env)
      matched_acl_record = self.class.acl.find_match(env["REQUEST_METHOD"], env["REQUEST_PATH"])

      if matched_acl_record
        rule_name = matched_acl_record.options[:rule] || self.class.configuration.default_rule
        rule = self.class.rules[rule_name]

        raise "Authorizer rule #{rule_name} not found." if rule.nil?

        if !rule.send("authorized?", claims, matched_acl_record)
          return [403, {'Content-Type' => 'text/plain'}, ["Unauthorized"]]
        end 
      end

      status, headers, response = @app.call(env)
    end

    def self.add_rule(rule_name, &block)
      rule ||= Class.new(ClaimsAuth::Rules::Base)
      rule.class_eval(&block) if block_given?
      rule_name = rule_name.to_s.squish.underscore.to_sym

      @rules[rule_name] = rule.new(rule_name)
    end

  end
end