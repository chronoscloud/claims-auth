require 'spec_helper'

describe ChronosAuthz::Validations::OptionsValidator do
  PRIMARY_COLORS = ["red", "yellow", "blue"].freeze

  class WithRequiredAndCheckConstraint < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator 
    required :some_required_attribute
    check_constraint :primary_color, PRIMARY_COLORS
  end

  class WithRequiredCheckConstraintOption < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator 
    check_constraint :primary_color, PRIMARY_COLORS, allow_nil: false
  end

  class WithCheckConstraint < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator 
    check_constraint :primary_color, ["red", "yellow", "blue"], allow_nil: true
  end

  class WithCaseSensitiveCheckConstraintOption < OpenStruct
    include ChronosAuthz::Validations::OptionsValidator 
    check_constraint :primary_color, ["red", "yellow", "blue"], case_sensitive: true
  end

  describe 'required options validation' do

    it 'raises a validation error if a required option is nil' do
      expect{ WithRequiredAndCheckConstraint.new.validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
    end

  end

  describe 'check constraint validation' do

    context 'when option value is a string' do
      it 'raises a validation error if the option value isn\'t found from the valid option values' do
        expect{ WithRequiredAndCheckConstraint.new(some_required_attribute: 'some_value', primary_color: "brown").validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
      end

      context 'with allow_nil config set to false' do
        it 'raises a validation error if option value is nil' do
          expect{ WithRequiredCheckConstraintOption.new.validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with allow_nil config set to true' do
        it 'doesn\'t raise any validation errors if option value is nil' do
          expect{ WithCheckConstraint.new.validate! }.to_not raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with case_sensitive config set to true' do
        it 'raises a validation error if option value is meaningfully equal to any of the valid option values but in different case' do
          expect{ WithCaseSensitiveCheckConstraintOption.new(primary_color: "RED").validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end
    end

    context 'when option value is an array' do
      it 'raises a validation error if an element from the option value isn\'t found from the valid option values' do
        expect{ WithRequiredAndCheckConstraint.new(some_required_attribute: 'some_value', primary_color: ["RED", "brown"]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
      end

      context 'with allow_nil config set to false' do
        it 'raises a validation error if an element from the option value is nil' do
          expect{ WithRequiredCheckConstraintOption.new(primary_color: ["blue", nil]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with allow_nil config set to true' do
        it 'doesn\'t raise any validation errors if an element from the option value is nil' do
          expect{ WithCheckConstraint.new(primary_color: ["blue", nil]).validate! }.to_not raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with case_sensitive config set to true' do
        it 'raises a validation error if an element from the option value is meaningfully equal to any of the valid option values but in different case' do
          expect{ WithCaseSensitiveCheckConstraintOption.new(primary_color: ["blue", "ReD"]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end
    end
  end
end