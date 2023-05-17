require 'rails_helper'

RSpec.describe PurchaseOrders::Process do
  describe '#call!' do
    subject(:service) { described_class.new(purchase_order: purchase_order) }

    let(:purchase_order) { create(:purchase_order, client: purchase_client, unit_price: unit_price, quantity: quantity) }
    let(:unit_price) { 10.0 }
    let(:quantity) { 7 }
    let(:purchase_client) { create(:client) }
    let!(:purchase_wallet) { create(:wallet, client: purchase_client, balance: 150.0) }

    let!(:sale_order) { create(:sale_order, client: sale_client, unit_price: unit_price, quantity: quantity, stocks: stocks_to_sale) }
    let(:sale_client) { create(:client) }
    let!(:sale_wallet) { create(:wallet, client: sale_client, balance: 250.0) }
    let(:stocks_to_sale) { create_list(:stock, 7, status: :on_sale, wallet: sale_wallet) }

    it 'creates stocks sale transaction' do
      expect { service.call! }.to change(StocksPurchaseTransaction, :count).by(1)
    end
  end
end
