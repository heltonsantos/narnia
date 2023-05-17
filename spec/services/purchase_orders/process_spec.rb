require 'rails_helper'

RSpec.describe PurchaseOrders::Process do
  describe '#call!' do
    subject(:service) { described_class.new(purchase_order: purchase_order) }

    let(:purchase_order) { create(:purchase_order, client: purchase_client, unit_price: unit_price, quantity: quantity) }
    let(:unit_price) { 10.0 }
    let(:quantity) { 7 }
    let(:purchase_client) { create(:client) }
    let!(:purchase_wallet) { create(:wallet, client: purchase_client, balance: 150.0) }
    let(:purchase_total_price) { unit_price * quantity }

    let!(:sale_order) { create(:sale_order, client: sale_client, unit_price: unit_price, quantity: quantity, stocks: stocks_to_sale) }
    let(:sale_client) { create(:client) }
    let!(:sale_wallet) { create(:wallet, client: sale_client, balance: 250.0) }
    let(:stocks_to_sale) { create_list(:stock, 7, status: :on_sale, wallet: sale_wallet) }

    let(:expected_stock_purchase_transaction_description) do
      "Purchase order ##{purchase_order.id} - #{purchase_order.quantity} stocks of #{purchase_order.stock_kind} " \
        "for #{purchase_order.unit_price} each - Total: #{purchase_total_price}"
    end

    let(:expected_stock_sale_transaction_description) do
      "Sale order ##{sale_order.id} - #{sale_order.quantity} stocks of #{sale_order.stock_kind} " \
        "for #{sale_order.unit_price} each - Total: #{purchase_total_price}"
    end

    it 'creates stocks purchase transaction' do
      expect { service.call! }.to change(StocksPurchaseTransaction, :count).by(1)

      expect(StocksPurchaseTransaction.last).to have_attributes(
        wallet_id: purchase_wallet.id,
        value: -70.0,
        description: expected_stock_purchase_transaction_description
      )
    end

    it 'updates purchase order status to completed' do
      expect { service.call! }.to change { purchase_order.reload.status }.from('pending').to('completed')
    end

    it 'updates purchase wallet balance' do
      expect { service.call! }.to change { purchase_wallet.reload.balance }.from(150.0).to(80.0)
    end

    it 'creates stocks sale transaction' do
      expect { service.call! }.to change(StocksSaleTransaction, :count).by(1)

      expect(StocksSaleTransaction.last).to have_attributes(
        wallet_id: sale_wallet.id,
        value: 70.0,
        description: expected_stock_sale_transaction_description
      )
    end

    it 'updates sale order status to completed' do
      expect { service.call! }.to change { sale_order.reload.status }.from('pending').to('completed')
    end

    it 'updates sale wallet balance' do
      expect { service.call! }.to change { sale_wallet.reload.balance }.from(250.0).to(320.0)
    end

    context 'when has not enough stocks on sale' do
      let(:stocks_to_sale) { create_list(:stock, 6, status: :on_sale, wallet: sale_wallet) }

      before do
        allow(ProcessPurchaseOrderWorker).to receive(:perform_in).and_return(true)
      end

      it 'enqueues worker' do
        service.call!

        expect(ProcessPurchaseOrderWorker).to have_received(:perform_in).with(10.minutes, purchase_order.id)
      end

      it 'does not create stocks purchase transaction' do
        expect { service.call! }.not_to change(StocksPurchaseTransaction, :count)
      end

      it 'update purchase order status' do
        expect { service.call! }.to change(purchase_order.reload, :status).from('pending').to('processing')
      end

      it 'does not update purchase wallet balance' do
        expect { service.call! }.not_to change(purchase_wallet.reload, :balance)
      end

      it 'does not create stocks sale transaction' do
        expect { service.call! }.not_to change(StocksSaleTransaction, :count)
      end

      it 'does not update sale order status' do
        expect { service.call! }.not_to change(sale_order.reload, :status)
      end

      it 'does not update sale wallet balance' do
        expect { service.call! }.not_to change(sale_wallet.reload, :balance)
      end

      context 'when purchase order is expired' do
        let(:purchase_order) do
          create(:purchase_order, client: purchase_client, unit_price: unit_price, quantity: quantity, expired_at: 1.day.ago)
        end

        it 'does not enqueue worker' do
          service.call!

          expect(ProcessPurchaseOrderWorker).not_to have_received(:perform_in)
        end

        it 'update purchase order status' do
          expect { service.call! }.to change(purchase_order.reload, :status).from('pending').to('expired')
        end

        it 'does not update purchase wallet balance' do
          expect { service.call! }.not_to change(purchase_wallet.reload, :balance)
        end

        it 'does not update sale order status' do
          expect { service.call! }.not_to change(sale_order.reload, :status)
        end

        it 'does not update sale wallet balance' do
          expect { service.call! }.not_to change(sale_wallet.reload, :balance)
        end
      end
    end
  end
end
