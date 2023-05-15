module PurchaseOrders
  class Create
    def initialize(client_uuid:, stock_kind:, unit_price:, quantity:)
      @client = Client.find_by(uuid: client_uuid)
      @stock_kind = stock_kind
      @unit_price = unit_price
      @quantity = quantity
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
          client_id: client.id
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
