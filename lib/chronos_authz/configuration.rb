module ChronosAuthz
  class Configuration < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator

    required :default_rule
  end
end  
