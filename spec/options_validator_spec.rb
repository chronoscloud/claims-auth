require 'spec_helper'

describe ChronosAuthz::Validations::OptionsValidator do

  let(:dummy_class) do
    Class.new(OpenStruct) { 
      include ChronosAuthz::Validations::OptionsValidator 
      required :some_required_attribute
      check_constraint :primary_color, ["red", "yellow", "blue"]
    }
  end

  let(:dummy_class_check_constraint_required) do
    Class.new(OpenStruct) { 
      include ChronosAuthz::Validations::OptionsValidator 
      check_constraint :primary_color, ["red", "yellow", "blue"], allow_nil: false
    }
  end

  let(:dummy_class_check_constraint_optional) do
    Class.new(OpenStruct) { 
      include ChronosAuthz::Validations::OptionsValidator 
      check_constraint :primary_color, ["red", "yellow", "blue"], allow_nil: true
    }
  end

  let(:dummy_class_check_constraint_case_sensitive) do
    Class.new(OpenStruct) { 
      include ChronosAuthz::Validations::OptionsValidator 
      check_constraint :primary_color, ["red", "yellow", "blue"], case_sensitive: true
    }
  end

  describe 'required options validation' do

    it 'raises a validation error if a required option is nil' do
      expect{ dummy_class.new.validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
    end

  end

  describe 'check constraint validation' do

    context 'when option value is a string' do
      it 'raises a validation error if the option value isn\'t found from the valid option values' do
        expect{ dummy_class.new(some_required_attribute: 'some_value', primary_color: "brown").validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
      end

      context 'with allow_nil config set to false' do
        it 'raises a validation error if option value is nil' do
          expect{ dummy_class_check_constraint_required.new.validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with allow_nil config set to true' do
        it 'doesn\'t raise any validation errors if option value is nil' do
          expect{ dummy_class_check_constraint_optional.new.validate! }.to_not raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with case_sensitive config set to true' do
        it 'raises a validation error if option value is meaningfully equal to any of the valid option values but in different case' do
          expect{ dummy_class_check_constraint_case_sensitive.new(primary_color: "RED").validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end
    end

    context 'when option value is an array' do
      it 'raises a validation error if an element from the option value isn\'t found from the valid option values' do
        expect{ dummy_class.new(some_required_attribute: 'some_value', primary_color: ["RED", "brown"]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
      end

      context 'with allow_nil config set to false' do
        it 'raises a validation error if an element from the option value is nil' do
          expect{ dummy_class_check_constraint_required.new(primary_color: ["blue", nil]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with allow_nil config set to true' do
        it 'doesn\'t raise any validation errors if an element from the option value is nil' do
          expect{ dummy_class_check_constraint_optional.new(primary_color: ["blue", nil]).validate! }.to_not raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end

      context 'with case_sensitive config set to true' do
        it 'raises a validation error if an element from the option value is meaningfully equal to any of the valid option values but in different case' do
          expect{ dummy_class_check_constraint_case_sensitive.new(primary_color: ["blue", "red"]).validate! }.to raise_error(ChronosAuthz::Validations::ValidationError)
        end
      end
    end
  end
end