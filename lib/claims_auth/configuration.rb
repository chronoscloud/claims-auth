require 'active_support/core_ext/object/blank'

module ClaimsAuth
  class Configuration

    attr_accessor :default_rule, :retrieve_claims_proc

    def initialize
      @default_rule = :default_rule
    end

    class MissingConfiguration < StandardError
      def initialize
        super('Configuration for ClaimsAuth::Authorizer missing!')
      end
    end

    def retrieve_claims(&block)
      @retrieve_claims_proc = block
    end

    def validate!
      raise MissingConfiguration if (@default_rule.blank? or @retrieve_claims_proc.blank?)
    end

  end
end