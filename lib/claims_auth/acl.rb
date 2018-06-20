require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/filters'

module ClaimsAuth

  class ACL
    attr_accessor :acl

    def self.load_from_configuration(configuration_path = nil)
      configuration_path ||= 'config/authorizer_acl.yml'

      return ACL.new(YAML.load_file(configuration_path))
    end

    def initialize(acl)
      @acl = acl
    end

    def find_match(http_method, resource_path)
      puts "Finding ACL match: [#{http_method}] #{resource_path}"
      @acl.each do |acl_record|
        acl_resource_path = sanitize_path(acl_record.last['path'])
        resource_path = sanitize_path(resource_path)
        path_pattern = /\A#{acl_resource_path}\z/

        method_matched = acl_record.last["method"].to_s.upcase == http_method.to_s.upcase
        path_matched = !resource_path.match(path_pattern).nil?

        if (method_matched && path_matched)
          puts "Found ACL match: #{acl_record.first}"
          return ACLRecord.new(acl_record.first, acl_record.last)
        end
      end

      return nil
    end

    def sanitize_path(resource_path)
      return resource_path.to_s.squish.gsub(/\/+$/, '')
    end

  end

  class ACLRecord
    attr_accessor :name, :options

    def initialize(name, options)
      @name = name
      @options = options.with_indifferent_access
    end
  end
end