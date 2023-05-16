class ProcessPurchaseOrdersWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    true
  end
end
