require 'rails_helper'

RSpec.describe SaleOrders::Create do
  describe '#call' do
    subject(:service) { described_class.new(params) }

    let(:params) do
      {
        client: client,
        stock_kind: :vibranium,
        unit_price: 10.0,
        quantity: 10
      }
    end

    let(:client) { create(:client) }

    let!(:wallet) { create(:wallet, client: client, balance: 150.0) }

    let!(:stocks) { create_list(:stock, 15, wallet: wallet) }

    context 'when there is enough balance' do
      it 'creates a purchase order' do
        expect { service.call! }.to change(SaleOrder, :count).by(1)
      end

      it 'creates with correct data' do
        service.call!

        sale_order = SaleOrder.last

        expect(sale_order).to have_attributes(
          client_id: client.id,
          unit_price: 10.0,
          quantity: 10,
          stock_kind: 'vibranium',
          stocks: be_a(ActiveRecord::Associations::CollectionProxy)
        )

        sale_order.stocks.all { |stock| expect(stock).to be_on_sale }
      end
    end

    context 'when there is not enough stocks' do
      let(:stocks) { create_list(:stock, 8, wallet: wallet) }

      it 'raises an error' do
        expect { service.call! }.to raise_error(Wallets::EnoughStocksError)
      end
    end

    context 'when provide invalid stock kind' do
      let(:params) do
        {
          client: client,
          stock_kind: :invalid,
          unit_price: 10.0,
          quantity: 10
        }
      end

      it 'raises an error' do
        expect { service.call! }.to raise_error(Stocks::InvalidStockKindError)
      end
    end
  end
end
