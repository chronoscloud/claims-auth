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
      matched_acl_record = @acl.find_match(env["REQUEST_METHOD"], env["REQUEST_PATH"])
      
      return render_unauthorized if @configuration.strict_mode && matched_acl_record.nil?

      request = Rack::Request.new(env)
      rule_class = matched_acl_record.try(:rule).try(:constantize) || @configuration.default_rule
      rule_instance = rule_class.new(request, matched_acl_record)    
      
      return render_unauthorized if !rule_instance.request_authorized?

      RequestStore.store[:chronos_authz_claims] = rule_instance.user_claims
      status, headers, response = @app.call(env)
    end

    def render_unauthorized
      if @configuration.unauthorized_page
        html = ActionView::Base.new.render(file: @configuration.unauthorized_page)
        return [403, {'Content-Type' => 'text/html'}, [html]]
      end
      return [403, {'Content-Type' => 'text/plain'}, ["Unauthorized"]]
    end
  end
end