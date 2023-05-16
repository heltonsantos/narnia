module PurchaseOrders
  class Create
    def initialize(client:, stock_kind:, unit_price:, quantity:, expired_at: nil)
      @client = client
      @stock_kind = stock_kind
      @unit_price = unit_price.to_f
      @quantity = quantity.to_i
      @expired_at = expired_at&.to_date || Time.zone.today
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      raise Wallets::EnoughBalanceError unless enough_balance?

      ActiveRecord::Base.transaction do
        purchase_order = PurchaseOrder.create!(
          uuid: SecureRandom.uuid,
          unit_price: unit_price,
          quantity: quantity,
          client_id: client.id,
          stock_kind: stock_kind,
          expired_at: expired_at
        )

        ProcessPurchaseOrderWorker.perform_in(1.minute, purchase_order.id)

        purchase_order
      end
    end

    private

    attr_reader :client, :stock_kind, :unit_price, :quantity, :expired_at

    def enough_balance?
      client.wallet.balance >= unit_price * quantity
    end
  end
end
