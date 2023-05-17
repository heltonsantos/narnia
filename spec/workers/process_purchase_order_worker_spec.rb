# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessPurchaseOrderWorker do
  describe '#perform' do
    let(:purchase_order_id) { purchase_order.id }
    let(:purchase_order) { create(:purchase_order) }

    before do
      described_class.perform_async(purchase_order_id)

      allow(PurchaseOrders::Process).to receive(:call!).and_return(true)
    end

    it { expect(described_class).to be_retryable true }
    it { expect(described_class).to be_processed_in('default') }
    it { expect(described_class).to have_enqueued_sidekiq_job(purchase_order_id) }

    it 'calls PurchaseOrders::Process service' do
      described_class.drain

      expect(PurchaseOrders::Process).to have_received(:call!).with(purchase_order: purchase_order)
    end
  end
end
