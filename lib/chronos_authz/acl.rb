module ChronosAuthz
  class ACL
    attr_accessor :yml, :records
      
    def initialize(authorizer_acl = nil)
      authorizer_acl ||= "config/authorizer_acl.yml"

      # begin  
        @yml = YAML.load_file(authorizer_acl)
        @records = build_records(@yml) || []
      # rescue StandardError => e
      #   raise ChronosAuthz::Validations::ValidationError.new("Unable to parse ACL #{authorizer_acl}: #{e.message}")
      # end
    end

    # Populate @records with instances of ACL::Record and validate each instances
    def build_records(records_hash_array)
      @records = records_hash_array.map do |record_name, record = {}| 
                   ChronosAuthz::ACL::Record.new(record.merge!(name: record_name)).validate!
                 end
    end

    # Find matching ACL Record
    def find_record(http_method, request_path)
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
      
      def initialize(value={})
        value = value.with_indifferent_access
        value[:http_method] = normalize_http_methods(value[:http_method])
        value[:path] = normalize_path(value[:path])

        super(value)
      end

      def matches?(http_method, request_path)
        request_path = normalize_path(request_path)
        path_pattern = /\A#{self.path}\z/

        method_matched = self.http_method.empty? || self.http_method.include?(http_method.upcase)

        return false if !method_matched
        return !request_path.match(path_pattern).nil?
      end

      private

      def normalize_path(resource_path)
        return resource_path.to_s.squish
      end

      def normalize_http_methods(http_methods)
        http_methods = [http_methods] if !http_methods.is_a? Array
        http_methods.map!{ |http_method| http_method.try(:upcase) }

        return http_methods.reject { |http_method| http_method.blank? }
      end
    end
  end
end