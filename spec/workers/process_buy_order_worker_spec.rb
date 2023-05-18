# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ProcessBuyOrderWorker do
  describe '#perform' do
    let(:buy_order) { create(:buy_order) }

    before do
      described_class.perform_async(buy_order.id)

      allow(BuyOrders::Process).to receive(:call!).and_return(true)
    end

    it 'calls BuyOrders::Process service' do
      described_class.drain

      expect(BuyOrders::Process).to have_received(:call!).with(buy_order: buy_order)
    end
  end
end
