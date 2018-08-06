module ChronoscloudAuthz
  module Rules
    class Base
      attr_reader :rule_name

      def initialize(rule_name)
        @rule_name = rule_name
      end

    end
  end
end