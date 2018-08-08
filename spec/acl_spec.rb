require 'spec_helper'
require 'chronos_authz/acl'

describe ChronosAuthz::ACL do
  let(:configuration_path) { 'spec/config/authorizer_acl.yml' }

  context 'initialization' do
    context 'when authorizer_acl is specified' do

      context 'with a corresponding YAML file' do
        it 'loads a YAML file from the authorizer_acl path' do
          expect(YAML).to receive(:load_file).with(configuration_path)
          puts "configuration"
          puts configuration_path
          puts YAML.load_file(configuration_path).inspect

          puts ChronosAuthz::ACL.new(configuration_path)
          ChronosAuthz::ACL.new(configuration_path)
        end
      end

      # it 'loads a YAML file from the configuration_path' do
      #   expect(YAML).to receive(:load_file).with('spec/config/authorizer_acl.yml')

      #   ChronosAuthz::ACL::ACL.new(configuration_path)
      # end
    end
  end

end
