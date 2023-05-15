require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:transaction)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:wallet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:uuid) }
    it { should validate_presence_of(:nature) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:value) }
  end
end