require 'rails_helper'

RSpec.describe SaleOrdersController, type: :controller do
  describe 'POST /clients/:uuid/sale_orders' do
    subject(:create_sale_orders) { post :create, params: params, format: :json }

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

    let!(:stocks) { create_list(:stock, 15, wallet: wallet) }

    context 'when there is enough stocks' do
      it 'creates a sale order' do
        expect { create_sale_orders }.to change(SaleOrder, :count).by(1)

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

      it 'creates a buy order' do
        expect { create_sale_orders }.to change(SaleOrder, :count).by(1)

        expect(response).to be_successful
        expect(response.status).to eq(201)
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
        expect { create_sale_orders }.not_to change(SaleOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Stock kind is invalid.' })
      end
    end

    context 'when there is not enough balance' do
      let(:stocks) { create_list(:stock, 8, wallet: wallet) }

      it 'raises an error' do
        expect { create_sale_orders }.not_to change(SaleOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'The wallet does not have enough stocks to complete the transaction.' })
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
        expect { create_sale_orders }.not_to change(SaleOrder, :count)

        expect(response).not_to be_successful
        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Couldn\'t find Client' })
      end
    end
  end
end
