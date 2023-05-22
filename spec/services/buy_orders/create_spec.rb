require 'rails_helper'

RSpec.describe BuyOrders::Create do
  describe '#call!' do
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

    before do
      allow(ProcessBuyOrderWorker).to receive(:perform_in).and_return(true)
    end

    context 'when there is enough balance' do
      it 'creates a buy order' do
        expect { service.call! }.to change(BuyOrder, :count).by(1)
      end

      it 'creates with correct data' do
        service.call!

        expect(BuyOrder.last).to have_attributes(
          client_id: client.id,
          unit_price: 10.0,
          quantity: 10,
          stock_kind: 'vibranium'
        )
      end

      it 'enqueues a worker' do
        service.call!

        expect(ProcessBuyOrderWorker).to have_received(:perform_in).with(1.minute, BuyOrder.last.uuid)
      end
    end

    context 'when there is not enough balance' do
      let(:wallet) { create(:wallet, client: client, balance: 50.0) }

      it 'raises an error' do
        expect { service.call! }.to raise_error(Wallets::EnoughBalanceError)

        expect(ProcessBuyOrderWorker).not_to have_received(:perform_in)
      end
    end
  end
end
