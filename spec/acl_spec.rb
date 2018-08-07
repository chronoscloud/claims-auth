require 'spec_helper'
require 'chronos_authz/acl/acl'

describe ChronosAuthz::ACL::ACL do
  let(:configuration_path) { 'spec/config/authorizer_acl.yml' }

  describe '.load_from_configuration' do
    context 'when configuration_path is specified' do
      it 'loads a YAML file from the configuration_path' do
        expect(YAML).to receive(:load_file).with('spec/config/authorizer_acl.yml')

        ChronosAuthz::ACL::ACL.new(configuration_path)
      end
    end
  end

end
