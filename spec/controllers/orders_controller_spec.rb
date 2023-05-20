require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'GET /clients/:uuid/orders' do
    subject(:query_orders) { get :index, params: params, format: :json }

    let(:params) { { client_uuid: client.uuid } }

    let(:client) { create(:client) }

    before do
      create_list(:buy_order, 5, client: client)
      create_list(:sale_order, 5, client: client)
    end

    it 'returns the orders' do
      query_orders

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(10)
    end

    context 'when provide a invalid client_uuid' do
      let(:params) { { client_uuid: 'abc' } }

      it 'raises an error' do
        expect { query_orders }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
