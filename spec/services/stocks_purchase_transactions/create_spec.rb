require 'rails_helper'

RSpec.describe StocksPurchaseTransactions::Create do
  describe '#call!' do
    subject(:service) { described_class.new(params) }

    let(:params) do
      {
        wallet: wallet,
        value: value,
        description: description
      }
    end

    let(:wallet) { create(:wallet, balance: 100.0) }
    let(:value) { 10.0 }
    let(:description) { 'Test' }

    it 'creates a new transaction' do
      expect { service.call! }.to change(StocksPurchaseTransaction, :count).by(1)
    end

    it 'creates a new transaction with correct attributes' do
      service.call!

      expect(StocksPurchaseTransaction.last).to have_attributes(
        wallet_id: wallet.id,
        value: -value,
        description: description
      )
    end

    it 'increase wallet balance' do
      expect { service.call! }.to change { wallet.reload.balance }.by(-value)
    end
  end
end
