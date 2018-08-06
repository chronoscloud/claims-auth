require 'yaml'
require 'chronos_authz/acl/record'

module ChronosAuthz
  module ACL
    class ACL
      attr_accessor :yml, :records
        
      def initialize(yml_path = "config/authorizer_acl.yml")
        @yml = YAML.load_file(yml_path)
        @records = build_records(@yml) || []
      end

      # Populate @records with instances of ACL::Record and validate each instances
      def build_records(records_hash_array)
        @records = records_hash_array.map{ |record_name, record| ChronosAuthz::ACL::Record.new(record.merge!(name: record_name)).validate! }
      end

      # Find matching ACL Record
      def find_record(http_method, request_path)
        record = @records.select{|record| record.matches?(http_method, request_path) }.first
        puts "Found ACL match: #{record.to_s}" if record

        return record
      end

    end
  end
end