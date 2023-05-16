require 'rails_helper'

RSpec.describe StocksSaleTransaction, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:stocks_sale_transaction)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:wallet) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:nature) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:value) }
  end
end
