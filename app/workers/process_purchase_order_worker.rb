class ProcessPurchaseOrderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    PurchaseOrders::Process.call!(purchase_order: PurchaseOrder.find(id))
  end
end
