require 'rails_helper'

RSpec.describe BuyOrdersController, type: :controller do
  describe 'POST /clients/:uuid/buy_orders' do
    subject(:create_buy_orders) { post :create, params: params, format: :json }

    let(:params) do
      {
        client_uuid: client.uuid,
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
        expect { create_buy_orders }.to change(BuyOrder, :count).by(1)

        expect(response).to be_successful
        expect(response.status).to eq(201)
        expect(ProcessBuyOrderWorker).to have_received(:perform_in).with(1.minute, BuyOrder.last.id)
      end
    end

    context 'when provide expired_at' do
      let(:params) do
        {
          client_uuid: client.uuid,
          stock_kind: :vibranium,
          unit_price: 10.0,
          quantity: 10,
          expired_at: 1.day.from_now
        }
      end

      it 'creates a buy order' do
        expect { create_buy_orders }.to change(BuyOrder, :count).by(1)

        expect(response).to be_successful
        expect(response.status).to eq(201)
        expect(ProcessBuyOrderWorker).to have_received(:perform_in).with(1.minute, BuyOrder.last.id)
      end
    end

    context 'when provide a invalid stock_kind' do
      let(:params) do
        {
          client_uuid: client.uuid,
          stock_kind: :abc,
          unit_price: 10.0,
          quantity: 10
        }
      end

      it 'raises an error' do
        expect { create_buy_orders }.not_to change(BuyOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Validation failed: Stock kind is invalid' })
        expect(ProcessBuyOrderWorker).not_to have_received(:perform_in)
      end
    end

    context 'when there is not enough balance' do
      let(:wallet) { create(:wallet, client: client, balance: 50.0) }

      it 'raises an error' do
        expect { create_buy_orders }.not_to change(BuyOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'The wallet does not have enough balance to complete the transaction.' })
        expect(ProcessBuyOrderWorker).not_to have_received(:perform_in)
      end
    end

    context 'when client not is found' do
      let(:params) do
        {
          client_uuid: SecureRandom.uuid,
          stock_kind: :vibranium,
          unit_price: 10.0,
          quantity: 10
        }
      end

      it 'raises an error' do
        expect { create_buy_orders }.not_to change(BuyOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Couldn\'t find Client' })
        expect(ProcessBuyOrderWorker).not_to have_received(:perform_in)
      end
    end
  end
end
