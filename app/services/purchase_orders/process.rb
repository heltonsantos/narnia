module PurchaseOrders
  class Process
    def initialize(purchase_order:)
      @purchase_order = purchase_order
      @wallet = @purchase_order.client.wallet
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      purchase_order.process!

      return reenqueue unless enough_stocks_on_sale?

      purchase_order.with_lock do
        StocksPurchaseTransactions::Create.call!(wallet: wallet, value: total_price, description: description)

        purchased_stocks.group_by(&:order).each do |sale_order, stocks_to_sell|
          SaleOrders::Process.call!(sale_order: sale_order, purchase_order: purchase_order, stocks_to_sell: stocks_to_sell)
        end

        purchase_order.stocks = purchased_stocks
        purchase_order.complete!
      end
    end

    private

    attr_reader :purchase_order, :wallet

    def stocks_on_sale
      @stocks_on_sale ||= Stock.stocks_on_sale(purchase_order.stock_kind)
    end

    def enough_stocks_on_sale?
      stocks_on_sale.count >= purchase_order.quantity
    end

    def reenqueue
      return purchase_order.expire! if purchase_order.expired_at < Date.current

      ProcessPurchaseOrderWorker.perform_in(10.minutes, purchase_order.id)
    end

    def total_price
      @total_price ||= purchase_order.unit_price * purchase_order.quantity
    end

    def description
      "Purchase order ##{purchase_order.id} - #{purchase_order.quantity} stocks of #{purchase_order.stock_kind} " \
        "for #{purchase_order.unit_price} each - Total: #{total_price}"
    end

    def purchased_stocks
      @purchased_stocks ||= stocks_on_sale.order(created_at: :asc).limit(purchase_order.quantity)
    end
  end
end
