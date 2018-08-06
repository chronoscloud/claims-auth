module ChronosAuthz
  module Validations
    class ValidationError < StandardError

      def initialize(message)
        super(message)
      end

    end
  end
end