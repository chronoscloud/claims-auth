module ChronosAuthz
  module User

    def claim(key)
      claims[key]
    end

    def claims
      RequestStore.store[:chronos_authz_claims]
    end

  end
end