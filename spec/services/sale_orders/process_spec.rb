require 'rails_helper'

RSpec.describe SaleOrders::Process do
  describe '#call!' do
    subject(:service) { described_class.new(sale_order: sale_order, buy_order: buy_order, stocks_to_sell: stocks_to_sell) }

    let(:sale_order) { create(:sale_order, client: sale_client, unit_price: unit_price, quantity: quantity, stocks: stocks_to_sale) }
    let(:buy_order) { create(:buy_order, client: buy_client, unit_price: unit_price, quantity: quantity) }
    let(:unit_price) { 10.0 }
    let(:quantity) { 7 }
    let(:sale_client) { create(:client) }
    let(:buy_client) { create(:client) }
    let!(:sale_wallet) { create(:wallet, client: sale_client, balance: 250.0) }
    let!(:buy_wallet) { create(:wallet, client: buy_client, balance: 150.0) }
    let(:stocks_to_sale) { create_list(:stock, 7, status: :on_sale, wallet: sale_wallet) }
    let(:stocks_to_sell) { stocks_to_sale }

    let(:expected_stock_sale_transaction_description) do
      "Sale order ##{sale_order.uuid} - #{sale_order.quantity} stocks of #{sale_order.stock_kind} " \
        "for #{sale_order.unit_price} each - Total: #{total_price}"
    end

    let(:total_price) { unit_price * quantity }

    it 'creates stocks sale transaction' do
      expect { service.call! }.to change(StocksSaleTransaction, :count).by(1)

      expect(StocksSaleTransaction.last).to have_attributes(
        wallet_id: sale_wallet.id,
        value: total_price,
        description: expected_stock_sale_transaction_description
      )
    end

    it 'updates sale order status to completed' do
      expect { service.call! }.to change { sale_order.reload.status }.from('pending').to('completed')
    end

    it 'creates timeline' do
      expect { service.call! }.to change { sale_order.timelines.count }.by(1)
      expect(sale_order.timelines.last.action).to eq('sale_order_processed')
      expect(sale_order.timelines.last.description).to eq(expected_stock_sale_transaction_description)
    end

    it 'updates sale wallet balance' do
      expect { service.call! }.to change { sale_wallet.reload.balance }.from(250.0).to(320.0)
    end

    context 'when is partial complete' do
      let(:stocks_to_sell) { stocks_to_sale.first(3) }
      let(:total_price) { unit_price * 3 }

      it 'creates stocks sale transaction' do
        expect { service.call! }.to change(StocksSaleTransaction, :count).by(1)

        expect(StocksSaleTransaction.last).to have_attributes(
          wallet_id: sale_wallet.id,
          value: 30.0,
          description: expected_stock_sale_transaction_description
        )
      end

      it 'updates sale order status to completed' do
        expect { service.call! }.to change { sale_order.reload.status }.from('pending').to('partial_completed')
      end

      it 'creates timeline' do
        expect { service.call! }.to change { sale_order.timelines.count }.by(1)
        expect(sale_order.timelines.last.action).to eq('sale_order_processed_with_partial_stock')
        expect(sale_order.timelines.last.description).to eq(expected_stock_sale_transaction_description)
      end

      it 'updates sale wallet balance' do
        expect { service.call! }.to change { sale_wallet.reload.balance }.from(250.0).to(280.0)
      end
    end

    context 'when is the same client' do
      let(:buy_client) { sale_client }

      it 'raises an error' do
        expect { service.call! }.to raise_error(Orders::SameClientError)
      end
    end
  end
end
