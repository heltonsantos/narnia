module PurchaseOrders
  class Create
    def initialize(client:, stock_kind:, unit_price:, quantity:)
      @client = client
      @stock_kind = stock_kind
      @unit_price = unit_price.to_f
      @quantity = quantity.to_i
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      raise Wallets::EnoughBalanceError unless enough_balance?

      ActiveRecord::Base.transaction do
        PurchaseOrder.create!(
          uuid: SecureRandom.uuid,
          unit_price: unit_price,
          quantity: quantity,
          client_id: client.id,
          stock_kind: stock_kind
        )
      end
    end

    private

    attr_reader :client, :stock_kind, :unit_price, :quantity

    def enough_balance?
      client.wallet.balance >= unit_price * quantity
    end
  end
end
