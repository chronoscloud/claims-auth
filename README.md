# chronos_authz
A declarative authorization Rack middleware that supports custom authorization logic on a per-resource basis

## Usage sample for Rails
### 1. Install the gem
```ruby
gem 'chronos_authz'
```

### 2. Configure the ACL config/my_acl.yml
An incoming request's http method and path will be checked against the ACL file's records for a match. At minimum, you MUST configure the path of the resource in an ACL record and SHOULD configure the http_method. If the http_method isn't configured, http method checking will not be done. You can define any other configuration here per resource as needed (ex. :permissions is a custom configuration and is defined here as this will be used in the custom authorization rule.
    
```ruby
manage_accounts:
  path: "/accounts/.*" # regex pattern
  http_method:  # if array is used, this would work as an OR operation: checking if the incoming http request's method matches ANY of the configured http_method
    - GET
    - put
  permissions:
    - VIEW_ACCOUNTS
    - UPDATE_ACCOUNTS

create_users:
  path: "/users"
  http_method: POST
  permissions:
    - CREATE_USERS
    
update_users:
  path: "/users/.*"
  http_method: PUT
  permissions:
    - UPDATE_USERS
    
  # rule: AnotherCustomRule # override the default rule
```

### 2. Create an authorization rule initializers/MyCustomRule.rb
An authorization rule MUST implement the __request_authorized?__ method. The rule has an access to the ff. instance variables:

1. @request - [__Rack::Request__](https://www.rubydoc.info/gems/rack/Rack/Request) for the incoming HTTP request
2. @acl_record - __ChronosAuthz::ACL::Record__ from the ACL yml that matches the incoming request's http method and path. Custom configuration in the ACL yaml will be accessible from this object. ex. @acl_record.permissions

```ruby
class MyCustomRule < ChronosAuthz::Rule
  
  # Must return a boolean to check
  def request_authorized?
    (@acl_record.permissions - user_claims).blank?
  end
  
  # Optional. Implement how claims are retrieved for a given user. Normally claims could be retrieved using cookies,
  # JWT/id_token decoded from the request header, API calls, or a database query. Any value returned here will be available to the ChronosAuthz::User.claims helper module as well.
  def user_claims
    # SAMPLE ONLY! In this sample configuration, only the user with the access token '1d1234913em23' would only be able to successfully send a POST request to /users. Access token 'm123493429304' bearer could both create and update a User.
    access_tokens = {
      "1d1234913em23" => ["CREATE_USERS"],
      "m123493429304" => ["CREATE_USERS", "UPDATE_USERS", "SomeOtherClaimInOtherFormat", "any-format-should-work-claim"]
    }
    
    access_token_from_request = < retrieve access token from @request object >
    return (access_tokens[access_token_from_request] || [])
  end
end
```

### 4. Use the middleware
```ruby
Rails.application.config.middleware.use ChronosAuthz::Authorizer do |config|
  # Required. Default authorization rule to use
  config.default_rule = MyCustomRule
  
  # Optional. Default is false. If set to true, the ACL is treated as a whitelist of resource paths: authorization would return a 403 error if no ACL Record has been configured for a given resource path. If set to false, authorization check will only be done to the resources configured in the ACL.
  config.strict_mode = true
  
  # Optional. Configure the error page to render when authorization fails 
  config.error_page = "public/403.html"
  
  # Optional. Default behavior will look for 'config/authorizer_acl.yml'. Configure which ACL yml to use
  config.acl_yaml = "config/my_acl.yml"
end
```

## Helpers
Include the helper module __ChronosAuthz::User__ as needed to have access to the current user's claims via the __.claims__ method.
example:
```ruby
class User < ActiveRecord
  include ChronosAuthz::User
end
```

With this helper included in your User model and assuming you are using Devise or any other AuthN solution, you may do the ff.:
```ruby
current_user.claims
=> ["CREATE_USERS"]
```

If the return value of user_claims method in your implementation is a hash:
```ruby
current_user.claims
=> {permissions: ["CREATE_USERS"], email: "someemail@yourdomain.com"}

current_user.claim[:email]
=> someemail@yourdomain.com
```


