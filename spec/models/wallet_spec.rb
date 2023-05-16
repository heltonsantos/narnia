require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:wallet)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to have_many(:stocks).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_presence_of(:balance) }
  end
end
