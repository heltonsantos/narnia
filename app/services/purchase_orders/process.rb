module PurchaseOrders
  class Create
    def initialize(id:)
      @purchase_order = PurchaseOrder.find(id)
      @wallet = @purchase_order.client.wallet
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      purchase_order.process!

      return reenqueue unless enough_stocks_to_buy?

      ActiveRecord::Base.transaction do
        wallet.with_lock do
          raise Wallets::EnoughBalanceError if enough_balance?

        end
      end
    end

    private

    attr_reader :purchase_order, :client

    def stocks_to_buy
      @stocks_to_buy ||= Stock.stocks_to_buy(purchase_order.stock_type)
    end

    def enough_stocks_to_buy?
      stocks_to_buy.count >= purchase_order.quantity
    end

    def reenqueue
      return purchase_order.expire! if purchase_order.expired_at > Time.zone.now

      ProcessPurchaseOrderWorker.perform_in(1.minute, purchase_order.id)
    end

    def total_price
      @total_price ||= purchase_order.unit_price * purchase_order.quantity
    end

    def enough_balance?
      wallet.balance >= unit_price * quantity
    end
  end
end
