class ProcessPurchaseOrderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    PurchaseOrders::Process.call!(id: id)
  end
end
