module ChronosAuthz
  class ACL
    attr_accessor :acl_hash, :records

    def self.build_from_yaml(acl_yaml = nil)
      acl_yaml ||= 'config/authorizer_acl.yml'
      acl_hash = YAML.load_file(acl_yaml)
      records = ACL.records_from_acl_hash(acl_hash)
      return ACL.new(records, acl_hash)
    end

    # Populate @records with instances of ACL::Record and validate each instances
    def self.records_from_acl_hash(acl_hash)
      return acl_hash.map do |record_name, record_options = {}| 
               ChronosAuthz::ACL::Record.new(record_options.merge!(name: record_name))
             end
    end

    def initialize(records = [], acl_hash = nil)
      @records = records
      @acl_hash = acl_hash
    end

    # Find matching ACL Record
    def find_match(http_method, request_path)
      record = @records.select{ |record| record.matches?(http_method, request_path) }.first
      puts "Found ACL match: #{record.to_s}" if record

      return record
    end


    class Record < OpenStruct
      include ChronosAuthz::Validations::OptionsValidator

      VALID_HTTP_METHODS = ["GET", 
                            "POST", 
                            "PUT", 
                            "PATCH", 
                            "DELETE", 
                            "HEAD"].freeze

      required :name, :path
      check_constraint :http_method, VALID_HTTP_METHODS, allow_nil: true

      def initialize(value = {})
        value = value.with_indifferent_access
        value[:http_method] = normalize_http_methods(value[:http_method])
        value[:path] = normalize_path(value[:path])

        super(value)
        validate!
      end

      def matches?(http_method, request_path)
        request_path = normalize_path(request_path)
        path_pattern = /\A#{self.path}\z/

        method_matched = self.http_method.empty? || self.http_method.include?(http_method.to_s.upcase)

        return false if !method_matched
        return !request_path.match(path_pattern).nil?
      end

      private

      def normalize_path(resource_path)
        return resource_path.to_s.squish
      end

      def normalize_http_methods(http_methods)
        http_methods = [http_methods] if !http_methods.is_a? Array
        http_methods.map!{ |http_method| http_method.to_s.upcase }

        return http_methods.reject { |http_method| http_method.blank? }
      end
    end
  end
end