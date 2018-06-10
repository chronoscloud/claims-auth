# claims-auth
Declarative claims-based AuthZ middleware

### Sample ACL records - config/authorizer_acl.yml
```ruby
create_users:
  method: "POST"
  path: /accounts
  permissions: 
    - USERS::CREATE

view_users:
  method: "GET"
  path: /accounts/*
  permissions: 
    - USERS::VIEW
```

### Sample Configuration - config/initializers/authorizer.rb
```ruby
Rails.application.config.middleware.use ClaimsAuth::Authorizer do |config|

  # Define how to retrieve the claims from the env that will be available to the
  # matched ACL record.
  config.retrieve_claims do |env|
    claims = {}
    claims[:user_id] = env["USER_ID"]
    claims
  end

  config.default_rule = :permission_claims_rule
end

ClaimsAuth::Authorizer.add_rule(:permission_claims_rule) do
  
  def authorized?(claims, acl_record)
    # logic to check the claims from the request against the acl_record's permission list
    
    return true
  end

end


```
