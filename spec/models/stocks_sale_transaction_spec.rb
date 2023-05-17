require 'rails_helper'

RSpec.describe StocksSaleTransaction, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:stocks_sale_transaction)).to be_valid }
  end

  context 'with relationships' do
    it { is_expected.to belong_to(:wallet) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:value) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#set_nature' do
        it 'set nature to inflow' do
          transaction = create(:stocks_sale_transaction, nature: :outflow)

          expect(transaction.nature).to eq('inflow')
        end
      end

      describe '#ensure_value' do
        it 'set value to positive' do
          transaction = create(:stocks_sale_transaction, value: -9.99)

          expect(transaction.value).to eq(9.99)
        end
      end
    end
  end
end
