class ProcessBuyOrderWorker
  include Sidekiq::Worker

  sidekiq_options retry: true, queue: :process_buy_order
  sidekiq_retry_in { 10.minutes }

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
