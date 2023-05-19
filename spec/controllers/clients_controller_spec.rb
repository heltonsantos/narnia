require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  describe 'GET /clients' do
    subject(:query_clients) { get :index, format: :json }

    let(:client) { create(:client) }
    let(:wallet) { create(:wallet, client: client) }

    before do
      create_list(:stock, 5, wallet: wallet)
      create_list(:stock, 5, wallet: wallet)
      create_list(:buy_order, 5, unit_price: 17.5, client: client)
      create_list(:buy_order, 5, unit_price: 17.5, status: :completed, client: client)
      create_list(:sale_order, 5, unit_price: 15.5, client: client)
      create_list(:sale_order, 5, unit_price: 15.5, status: :completed, client: client)
      create_list(:stocks_buy_transaction, 5, wallet: wallet)
      create_list(:stocks_sale_transaction, 5, wallet: wallet)
    end

    it 'returns the clients' do
      query_clients

      expect(response).to be_successful
      expect(response.status).to eq(200)

      expected_client = JSON.parse(response.body).find { |c| c['id'] == client.id }

      expect(expected_client).to eq(
        {
          'id' => client.id,
          'uuid' => client.uuid,
          'name' => client.name,
          'balance' => wallet.balance.to_s,
          'stocks_summary' => {
            'vibranium.available' => 10
          },
          'orders_summary' => {
            'BuyOrder.completed' => 5,
            'BuyOrder.pending' => 5,
            'SaleOrder.completed' => 5,
            'SaleOrder.pending' => 5
          },
          'transactions_summary' => {
            'StocksBuyTransaction.outflow' => 5,
            'StocksSaleTransaction.inflow' => 5
          }
        }
      )
    end
  end
end
