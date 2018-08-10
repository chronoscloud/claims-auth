module ChronosAuthz::Spec
  module Helpers
    class CustomRule < ChronosAuthz::Rule
      def request_authorized?
        true
      end
    end
  end
end