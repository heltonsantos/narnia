class ProcessBuyOrderWorker
  include Sidekiq::Worker

  sidekiq_options queue: :process_buy_order, retry: true
  sidekiq_retry_in { Rails.configuration.worker.process_buy_order_worker_retry_in.to_i.minutes }

  def perform(uuid)
    buy_order = BuyOrder.find_by(uuid: uuid)

    begin
      BuyOrders::Process.call!(buy_order: buy_order)
    rescue StandardError => e
      buy_order.timelines.create!(action: 'buy_order_retried', description: e.message)
      buy_order.error_message = e.message
      buy_order.retry_count += 1
      buy_order.retry!

      raise e
    end
  end
end
