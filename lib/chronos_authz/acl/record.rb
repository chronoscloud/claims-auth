require 'ostruct'
require 'chronos_authz/validations/options_validator'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/indifferent_access'


module ChronosAuthz
  module ACL
    class Record < OpenStruct
      include ChronosAuthz::Validations::OptionsValidator

      HTTP_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD"].freeze

      required :name, :path
      check_constraint :http_method, HTTP_METHODS, allow_nil: true
      
      def initialize(value={})
        value = value.with_indifferent_access
        value["http_method"] = [value["http_method"]] if !value["http_method"].is_a? Array
        value["http_method"] = value["http_method"].map{|http_method| http_method.try(:upcase) } - [nil, ""]

        value["path"] = sanitize_path(value["path"])

        super(value)
      end

      def matches?(http_method, request_path)
        request_path = sanitize_path(request_path)
        path_pattern = /\A#{self.path}\z/

        method_matched = self.http_method.empty? || self.http_method.include?(http_method.upcase)

        return false if !method_matched
        return !request_path.match(path_pattern).nil?
      end

      def sanitize_path(resource_path)
        return resource_path.to_s.squish
        # return resource_path.to_s.squish.gsub(/\/+$/, '')
      end
    end
  end
end