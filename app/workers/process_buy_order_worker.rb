class ProcessBuyOrderWorker
  include Sidekiq::Worker

  sidekiq_options retry: true, queue: :process_buy_order
  sidekiq_retry_in { 10.minutes }

  def perform(id)
    BuyOrders::Process.call!(buy_order: BuyOrder.find(id))
  end
end
