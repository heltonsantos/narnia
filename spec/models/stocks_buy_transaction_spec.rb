require 'rails_helper'

RSpec.describe StocksBuyTransaction, type: :model do
  describe 'FactoryBot' do
    it { expect(build(:stocks_buy_transaction)).to be_valid }
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
      describe '#set_uuid' do
        it 'set uuid' do
          transaction = create(:stocks_sale_transaction, uuid: nil)

          expect(transaction.uuid).to be_present
        end
      end

      describe '#set_nature' do
        it 'set nature to outflow' do
          transaction = create(:stocks_buy_transaction, nature: :inflow)

          expect(transaction.nature).to eq('outflow')
        end
      end

      describe '#ensure_value' do
        it 'set value to negative' do
          transaction = create(:stocks_buy_transaction, value: 9.99)

          expect(transaction.value).to eq(-9.99)
        end
      end
    end
  end
end
