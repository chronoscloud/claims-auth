require 'ostruct'
require 'chronos_authz/validations/options_validator'

module ChronosAuthz
  class Configuration < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator

    required :strict_mode, :default_rule
  end
end  
