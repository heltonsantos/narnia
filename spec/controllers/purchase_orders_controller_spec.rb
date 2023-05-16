require 'rails_helper'

RSpec.describe PurchaseOrdersController, type: :controller do
  describe 'POST /purchase_orders' do
    subject(:create_purchase_orders) { post :create, params: params, format: :json }

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

    context 'when there is enough balance' do
      it 'creates a purchase order' do
        expect { create_purchase_orders }.to change(PurchaseOrder, :count).by(1)

        expect(response).to be_successful
        expect(response.status).to eq(201)
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

      it 'creates a purchase order' do
        expect { create_purchase_orders }.to change(PurchaseOrder, :count).by(1)

        expect(response).to be_successful
        expect(response.status).to eq(201)
      end
    end

    context 'when there is not enough balance' do
      let(:wallet) { create(:wallet, client: client, balance: 50.0) }

      it 'raises an error' do
        expect { create_purchase_orders }.not_to change(PurchaseOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'The wallet does not have enough balance to complete the transaction.' })
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
        expect { create_purchase_orders }.not_to change(PurchaseOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Couldn\'t find Client' })
      end
    end
  end
end
