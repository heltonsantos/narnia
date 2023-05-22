# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ProcessBuyOrderWorker do
  describe '#perform' do
    let(:buy_order) { create(:buy_order) }

    before do
      described_class.perform_async(buy_order.uuid)

      allow(BuyOrders::Process).to receive(:call!).and_return(true)
    end

    it { is_expected.to be_retryable true }

    it 'calls BuyOrders::Process service' do
      described_class.drain

      expect(BuyOrders::Process).to have_received(:call!).with(buy_order: buy_order)
    end

    context 'when BuyOrders::Process service raises an error' do
      before do
        allow(BuyOrders::Process).to receive(:call!).and_raise(StandardError, 'Boom!')
      end

      it 'retries the job' do
        expect { described_class.drain }.to raise_error(StandardError)

        expect(buy_order.reload).to be_retrying
        expect(buy_order.retry_count).to eq(1)
        expect(buy_order.error_message).to eq('Boom!')
        expect(buy_order.retryed_at).to be_present
        expect(buy_order.timelines.last).to have_attributes(action: 'buy_order_retried', description: 'Boom!')
      end
    end
  end
end
