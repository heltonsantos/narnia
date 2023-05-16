require 'rails_helper'

RSpec.describe PurchaseOrders::Create do
  describe '#call' do
    subject(:service) { described_class.new(params) }

    let(:params) do
      {
        client: client,
        stock_kind: :vibranium,
        unit_price: 10.0,
        quantity: 10
      }
    end

    let(:client) { create(:client) }

    let!(:wallet) { create(:wallet, client: client, balance: 150.0) }

    context 'when there is enough balance' do
      it 'creates a purchase order' do
        expect { service.call! }.to change(PurchaseOrder, :count).by(1)
      end

      it 'creates with correct data' do
        service.call!

        expect(PurchaseOrder.last).to have_attributes(
          client_id: client.id,
          unit_price: 10.0,
          quantity: 10
        )
      end
    end

    context 'when there is not enough balance' do
      let(:wallet) { create(:wallet, client: client, balance: 50.0) }

      it 'raises an error' do
        expect { service.call! }.to raise_error(Wallets::EnoughBalanceError)
      end
    end
  end
end
