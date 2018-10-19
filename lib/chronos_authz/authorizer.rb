module ChronosAuthz

  class Authorizer

    attr_accessor :configuration, :acl

    def initialize(app, options = {})
      @app, @configuration = app, ::ChronosAuthz::Configuration.new(options)

      yield @configuration if block_given?
      @configuration.validate!
      @acl = ChronosAuthz::ACL.build_from_yaml(@configuration.acl_yaml)
    end


    def call(env)
      matched_acl_record = @acl.find_match(env["REQUEST_METHOD"], env["PATH_INFO"])
      
      return render_unauthorized if @configuration.strict_mode && matched_acl_record.nil?

      if !matched_acl_record.nil?
        request = Rack::Request.new(env)
        rule_class = matched_acl_record.try(:rule).try(:constantize) || @configuration.default_rule
        @rule_instance = rule_class.new(request, matched_acl_record)    
        
        return render_unauthorized if !@rule_instance.request_authorized?

        RequestStore.store[:chronos_authz_claims] = @rule_instance.user_claims
      end

      status, headers, response = @app.call(env)
    end

    def render_unauthorized
      if !@rule_instance.json_error.nil?
        return [403, {'Content-Type' => 'application/json'}, [@rule_instance.json_error.to_json]]
      elsif !@rule_instance.html_error.nil?
        return [403, {'Content-Type' => 'text/html'}, [@rule_instance.html_error]]
      elsif @configuration.error_page
        # html = ActionView::Base.new.render(file: @configuration.error_page)
        return [403, {'Content-Type' => 'text/html'}, [File.read(@configuration.error_page)]]
      end
      return [403, {'Content-Type' => 'text/plain'}, ["Unauthorized"]]
    end
  end
end