require 'rails_helper'

RSpec.describe BookOrdersController, type: :controller do
  describe 'GET /order_books' do
    subject(:query_order_books) { get :index, format: :json }

    let(:client) { create(:client) }

    before do
      create(:buy_order, client: client, unit_price: 10.0, quantity: 10)
      create(:sale_order, client: client, unit_price: 10.0, quantity: 10)
    end

    it 'returns the book orders' do
      query_order_books

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(response.body).to eq({
        buy_orders: { '10.0.pending' => 1 },
        sale_orders: { '10.0.pending' => 1 }
      }.to_json)
    end
  end
end
