# claims-auth
Declarative claims-based AuthZ middleware (still under development)

## Usage
1. create authorizer_acl.yml to define routes/resources that needs to be protected
2. create initializer/configuration authorizer.rb to implement your authorization logic

### Sample ACL records - config/authorizer_acl.yml
An incoming request's http method and path will be checked against this file's entries for a match. You can define any other configuration here as needed (ex. permissions is defined here as this will be used in the custom authorization logic :permission_claims_rule).
```ruby
create_users:
  method: "POST"
  path: /users 
  permissions: 
    - USERS::CREATE

view_users:
  method: "GET"
  path: /users/.*  #regex
  permissions: 
    - USERS::VIEW
```

### Sample Configuration - config/initializers/authorizer.rb
In this sample configuration, only the user with the access token 'm123493429304' would be able to successfully send a POST request to /users. Access token '1d1234913em23' bearer could GET to /users/ though.
```ruby
# Sample method/data only. You would normally fetch permissions via JWT/DB/API calls.
def user_permissions_from_access_token(access_token)
  access_tokens = {
    "1d1234913em23" => ["USERS::VIEW"],
    "m123493429304" => ["USERS::VIEW","USERS::CREATE","SomeOtherClaimInOtherFormat", "any-format-should-work-claim"]
  }
  return (access_tokens[access_token] || [])
end

# Configuration
Rails.application.config.middleware.use ClaimsAuth::Authorizer do |config|

  # Define how to retrieve the claims from the Rack env. Whatever this block returns will be available in the 'claims' parameter in
  # the Rule#authorized? checking
  config.retrieve_claims do |env|
    claims = {}
    claims[:access_token] = env["HTTP_AUTHORIZATION"].gsub("Bearer ",'')
    claims[:user_claims] =  user_permissions_from_access_token(claims[:access_token]) # sample only. user claims should be retrieved from the DB/via API calls/JWT.
    claims
  end

  config.default_rule = :permission_claims_rule
end

ClaimsAuth::Authorizer.add_rule(:permission_claims_rule) do
  
  # Actual authorization login goes here. 
  # claims - return value from the config.retrieve_claims block
  # acl_record - matched ACL entry from the authorizer_acl.yml
  def authorized?(claims, acl_record)
    return (acl_record.options[:permissions] - claims[:user_claims]).empty?
  end
end



```
