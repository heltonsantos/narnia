require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET /clients/:uuid/transactions' do
    subject(:query_transactions) { get :index, params: params, format: :json }

    let(:params) { { client_uuid: client.uuid } }

    let(:client) { create(:client) }
    let(:wallet) { create(:wallet, client: client) }

    before do
      create_list(:stocks_buy_transaction, 5, wallet: wallet)
      create_list(:stocks_sale_transaction, 5, wallet: wallet)
    end

    it 'returns the transactions' do
      query_transactions

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(10)
    end

    context 'when provide a invalid client_uuid' do
      let(:params) { { client_uuid: 'abc' } }

      it 'raises an error' do
        expect { query_transactions }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
