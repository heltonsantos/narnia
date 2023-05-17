class ProcessPurchaseOrderWorker
  include Sidekiq::Worker

  sidekiq_options retry: true
  sidekiq_retry_in { 10.minutes }

  def perform(id)
    PurchaseOrders::Process.call!(purchase_order: PurchaseOrder.find(id))
  end
end
