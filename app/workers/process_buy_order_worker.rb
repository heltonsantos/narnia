class ProcessBuyOrderWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: true
  sidekiq_retry_in { Rails.configuration.worker.process_buy_order_worker_retry_in.to_i.minutes }

  def perform(id)
    buy_order = BuyOrder.find(id)

    begin
      BuyOrders::Process.call!(buy_order: buy_order)
    rescue StandardError => e
      buy_order.error_message = e.message
      buy_order.retry_count += 1
      buy_order.retry!

      raise e
    end
  end
end
