# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessBuyOrderWorker do
  describe '#perform' do
    let(:buy_order_id) { buy_order.id }
    let(:buy_order) { create(:buy_order) }

    before do
      described_class.perform_async(buy_order_id)

      allow(BuyOrders::Process).to receive(:call!).and_return(true)
    end

    it { expect(described_class).to be_retryable true }
    it { expect(described_class).to be_processed_in('default') }
    it { expect(described_class).to have_enqueued_sidekiq_job(buy_order_id) }

    it 'calls BuyOrders::Process service' do
      described_class.drain

      expect(BuyOrders::Process).to have_received(:call!).with(buy_order: buy_order)
    end
  end
end
