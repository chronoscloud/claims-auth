module ChronosAuthz
  class Rule
    
    attr_accessor :request, :acl_record

    def initialize(request, acl_record)
      @request = request
      @acl_record = acl_record
    end

    def user_claims
      nil
    end
    
    def request_authorized?
      false
    end
    
    def json_error
      nil
    end

    def html_error
      nil
    end
    
  end
end