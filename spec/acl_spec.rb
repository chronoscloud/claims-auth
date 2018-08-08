require 'spec_helper'

describe ChronosAuthz::ACL do
  let(:acl_yaml) { 'spec/config/authorizer_acl_test.yml' }

  describe 'attribute accessors' do
    it 'assigns acl_hash' do
      acl_object = ChronosAuthz::ACL.build_from_yaml(acl_yaml)

      expect(acl_object.acl_hash).to_not be_nil
    end

    it 'assigns records' do
      acl_object = ChronosAuthz::ACL.build_from_yaml(acl_yaml)

      expect(acl_object.records).to_not be_empty
    end
  end

  describe '.build_from_yaml' do
   context 'when acl_yaml is specified' do
     it 'loads a YAML file from the acl_yaml' do
       allow(YAML).to receive(:load_file).and_return(YAML.load_file(acl_yaml))
       expect(YAML).to receive(:load_file).with(acl_yaml)

       ChronosAuthz::ACL.build_from_yaml(acl_yaml)
     end
   end

   context 'when no acl_yaml is specified' do
      it 'loads a YAML file using a default path' do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file(acl_yaml))
        expect(YAML).to receive(:load_file).with('config/authorizer_acl.yml')

        ChronosAuthz::ACL.build_from_yaml
      end
    end

    it 'initializes a new ACL' do
      expect(ChronosAuthz::ACL).to receive(:new)

      ChronosAuthz::ACL.build_from_yaml(acl_yaml)
    end

    it 'returns an ACL object' do
      expect(ChronosAuthz::ACL.build_from_yaml(acl_yaml)).to be_an_instance_of(ChronosAuthz::ACL)
    end

  end

  describe '.records_from_acl_hash' do
    it 'returns an array of ACL::Record from a YAML hash' do
      records = ChronosAuthz::ACL.records_from_acl_hash(YAML.load_file(acl_yaml))
      expect(records).to_not be_empty
      expect(records).to all(be_an(ChronosAuthz::ACL::Record))
    end
  end 

  describe '#find_match' do
    let(:acl) { ChronosAuthz::ACL.build_from_yaml(acl_yaml) }

    context 'when using valid parameters' do
      context 'when http_method and request_path is in config' do

        it 'returns an ACLRecord' do
          expect(acl.find_match('POST', '/users')).to be_an_instance_of(ChronosAuthz::ACL::Record)
        end

        it 'finds the record that matches the path pattern' do
          expect(acl.find_match('GET', '/accounts/2')).to_not be_nil
        end
      end

      context 'when http_method is not in config' do
        it 'returns nil' do
          expect(acl.find_match('DELETE', '/users')).to be_nil
        end
      end

      context 'when request_path is not in config' do
        it 'returns nil' do
          expect(acl.find_match('GET', '/test')).to be_nil
          expect(acl.find_match('POST', '/users////')).to be_nil
          expect(acl.find_match('POST', '/user/1/1/1/')).to be_nil
        end
      end
    end

    context 'when using null parameters' do
      context 'when http_method is null' do
        it 'returns nil' do
          expect(acl.find_match(nil, '/test')).to be_nil
        end
      end

      context 'when resource_path is null' do
        it 'returns nil' do
          expect(acl.find_match('GET', 'nil')).to be_nil
        end
      end
    end
  end
end


describe ChronosAuthz::ACL::Record do
  # describe 'attribute accessors' do
  #   let(:acl_record) { ClaimsAuth::ACLRecord.new('create_users', {'method'=>'POST', 'path'=>'/users', 'permissions'=>['USERS::CREATE']}) }

  #   it 'assigns name' do
  #     expect(acl_record.name).to eql('create_users')
  #   end

  #   it 'assigns options' do
  #     expect(acl_record.options).to eql({'method'=>'POST', 'path'=>'/users', 'permissions'=>['USERS::CREATE']})
  #   end
  # end
end
