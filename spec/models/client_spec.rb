require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:client)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to have_one(:wallet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:uuid) }
    it { should validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
