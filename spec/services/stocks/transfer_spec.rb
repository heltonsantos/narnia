require 'rails_helper'

RSpec.describe Stocks::Transfer do
  describe '#call!' do
    subject(:service) { described_class.new(stocks: stocks, wallet: wallet) }

    let(:stocks) { create_list(:stock, 10, status: :on_sale) }

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
  end
end
