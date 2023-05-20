require 'rails_helper'

RSpec.describe Stocks::Transfer do
  describe '#call!' do
    subject(:service) { described_class.new(stocks: stocks, wallet: wallet) }

    let(:stocks) { create_list(:stock, 10, status: :on_sale, order: order, wallet: current_wallet) }
    let(:current_wallet) { create(:wallet) }
    let(:order) { create(:sale_order) }
    let(:wallet) { create(:wallet) }

    it 'transfers stocks to wallet' do
      expect { service.call! }.to change(wallet.stocks, :count).by(10)
    end

    it 'changes stocks wallet' do
      service.call!

      expect(stocks.all? { |stock| stock.reload.wallet == wallet }).to be_truthy
    end

    it 'changes stocks state to in_wallet' do
      service.call!

      expect(stocks).to be_all(&:available?)
    end

    it 'changes stocks order to nil' do
      service.call!

      expect(stocks).to be_all { |stock| stock.order.nil? }
    end

    it 'creates timeline for each stock' do
      expect { service.call! }.to change(Timeline, :count).by(10)
    end

    it 'creates timeline with correct action' do
      service.call!

      stocks.each do |stock|
        expect(stock.reload.timelines.first.action).to eq('stock_transferred')
        expect(stock.reload.timelines.first.description).to eq(
          "Stock transferred from #{current_wallet.client.name} to #{wallet.client.name} by order #{order.uuid}"
        )
      end
    end
  end
end
