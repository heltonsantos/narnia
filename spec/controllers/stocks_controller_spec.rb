require 'rails_helper'

RSpec.describe StocksController, type: :controller do
  describe 'GET /clients/:uuid/stocks' do
    subject(:query_stocks) { get :index, params: params, format: :json }

    let(:params) { { client_uuid: client.uuid } }

    let(:client) { create(:client) }
    let(:wallet) { create(:wallet, client: client) }

    before do
      create_list(:stock, 5, wallet: wallet)
    end

    it 'returns the stocks' do
      query_stocks

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(5)
    end

    context 'when provide a invalid client_uuid' do
      let(:params) { { client_uuid: 'abc' } }

      it 'raises an error' do
        expect { query_stocks }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
