# require 'active_support/core_ext/string/filters'
# require 'active_support/core_ext/string/filters'

module ChronosAuthz

  class Authorizer

    attr_accessor :configuration, :acl

    def initialize(app, options={})
      @app, @configuration = app, ChronosAuthz::Configuration.new(options)
      @acl = ChronosAuthz::ACL::ACL.new

      yield @configuration if block_given?
      @configuration.validate!
    end


    def call(env)
      matched_acl_record = @acl.find_record(env["REQUEST_METHOD"], env["REQUEST_PATH"])
      
      # claims = @configuration.retrieve_claims_proc.call(env)
      # if matched_acl_record
      #   rule_name = matched_acl_record.options[:rule] || self.class.configuration.default_rule
      #   rule = self.class.rules[rule_name]

      #   raise "Authorizer rule #{rule_name} not found." if rule.nil?

      #   if !rule.send("authorized?", claims, matched_acl_record)
      #     return [403, {'Content-Type' => 'text/plain'}, ["Unauthorized"]]
      #   end 
      # end

      status, headers, response = @app.call(env)
    end

    # def self.add_rule(rule_name, &block)
    #   rule ||= Class.new(ChronosAuthz::Rules::Base)
    #   rule.class_eval(&block) if block_given?
    #   rule_name = rule_name.to_s.squish.underscore.to_sym

    #   @rules[rule_name] = rule.new(rule_name)
    # end

  end
end