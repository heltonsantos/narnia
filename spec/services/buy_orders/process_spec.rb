require 'rails_helper'

RSpec.describe BuyOrders::Process do
  describe '#call!' do
    subject(:service) { described_class.new(buy_order: buy_order) }

    let(:buy_order) { create(:buy_order, client: buy_client, unit_price: unit_price, quantity: quantity) }
    let(:unit_price) { 10.0 }
    let(:quantity) { 7 }
    let(:buy_client) { create(:client) }
    let!(:buy_wallet) { create(:wallet, client: buy_client, balance: 150.0) }
    let(:buy_total_price) { unit_price * quantity }

    let!(:sale_order) { create(:sale_order, client: sale_client, unit_price: unit_price, quantity: quantity, stocks: stocks_to_sale) }
    let(:sale_client) { create(:client) }
    let!(:sale_wallet) { create(:wallet, client: sale_client, balance: 250.0) }
    let(:stocks_to_sale) { create_list(:stock, 7, status: :on_sale, wallet: sale_wallet) }

    let(:expected_stock_buy_transaction_description) do
      "Buy order ##{buy_order.uuid} - #{buy_order.quantity} stocks of #{buy_order.stock_kind} " \
        "for #{buy_order.unit_price} each - Total: #{buy_total_price}"
    end

    let(:expected_stock_sale_transaction_description) do
      "Sale order ##{sale_order.uuid} - #{sale_order.quantity} stocks of #{sale_order.stock_kind} " \
        "for #{sale_order.unit_price} each - Total: #{buy_total_price}"
    end

    it 'creates stocks buy transaction' do
      expect { service.call! }.to change(StocksBuyTransaction, :count).by(1)

      expect(StocksBuyTransaction.last).to have_attributes(
        wallet_id: buy_wallet.id,
        value: -70.0,
        description: expected_stock_buy_transaction_description
      )
    end

    it 'updates buy order status to completed' do
      expect { service.call! }.to change { buy_order.reload.status }.from('pending').to('completed')
    end

    it 'creates timeline' do
      expect { service.call! }.to change { buy_order.timelines.count }.by(1)
      expect(buy_order.timelines.last.action).to eq('buy_order_processed')
      expect(buy_order.timelines.last.description).to eq(expected_stock_buy_transaction_description)
    end

    it 'updates buy wallet balance' do
      expect { service.call! }.to change { buy_wallet.reload.balance }.from(150.0).to(80.0)
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
        allow(ProcessBuyOrderWorker).to receive(:perform_in).and_return(true)
      end

      it 'enqueues worker' do
        service.call!

        expect(ProcessBuyOrderWorker).to have_received(:perform_in).with(10.minutes, buy_order.id)
      end

      it 'creates timeline' do
        expect { service.call! }.to change { buy_order.timelines.count }.by(1)
        expect(buy_order.timelines.last.action).to eq('buy_order_requeued')
        expect(buy_order.timelines.last.description).to eq('Buy order requeued by not enough stocks on sale')
      end

      it 'does not create stocks buy transaction' do
        expect { service.call! }.not_to change(StocksBuyTransaction, :count)
      end

      it 'update buy order status' do
        expect { service.call! }.to change(buy_order.reload, :status).from('pending').to('processing')
      end

      it 'does not update buy wallet balance' do
        expect { service.call! }.not_to change(buy_wallet.reload, :balance)
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

      context 'when buy order is expired' do
        let(:buy_order) do
          create(:buy_order, client: buy_client, unit_price: unit_price, quantity: quantity, expired_at: 1.day.ago)
        end

        it 'does not enqueue worker' do
          service.call!

          expect(ProcessBuyOrderWorker).not_to have_received(:perform_in)
        end

        it 'update buy order status' do
          expect { service.call! }.to change(buy_order.reload, :status).from('pending').to('expired')
        end

        it 'does not update buy wallet balance' do
          expect { service.call! }.not_to change(buy_wallet.reload, :balance)
        end

        it 'does not update sale order status' do
          expect { service.call! }.not_to change(sale_order.reload, :status)
        end

        it 'does not update sale wallet balance' do
          expect { service.call! }.not_to change(sale_wallet.reload, :balance)
        end
      end
    end

    context 'when raise error' do
      before do
        allow(StocksSaleTransaction).to receive(:create!).and_raise(StandardError)
      end

      it 'does rollback and raise error' do
        expect { service.call! }.to raise_error(StandardError)

        expect(StocksBuyTransaction.count).to eq(0)
        expect(buy_order.reload.status).to eq('processing')
        expect(buy_wallet.reload.balance).to eq(150.0)
        expect(StocksSaleTransaction.count).to eq(0)
        expect(sale_order.reload.status).to eq('pending')
        expect(sale_wallet.reload.balance).to eq(250.0)
      end
    end
  end
end
