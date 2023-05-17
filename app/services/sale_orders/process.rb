module SaleOrders
  class Create
    def initialize(sale_order:, purchase_order:, stocks_to_sell:)
      @sale_order = sale_order
      @purchase_order = purchase_order
      @wallet = @sale_order.client.wallet
      @stocks_to_sell = stocks_to_sell
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      sale_order.process!

      ActiveRecord::Base.transaction do
        StocksSaleTransactions::Create.call!(wallet: wallet, value: total_price, description: description)

        sale_order.with_lock do
          sale_order.stocks = sale_order.stocks - stocks_to_sell

          sale_order.stocks.empty? ? sale_order.complete! : sale_order.partial_complete!
        end
      end
    end

    private

    attr_reader :sale_order, :purchase_order, :wallet, :stocks_to_sell

    def total_price
      @total_price ||= sale_order.unit_price * stocks_to_sell.count
    end

    def description
      "Sale order ##{sale_order.id} - #{sale_order.quantity} stocks of #{sale_order.stock_type} " \
        "for #{sale_order.unit_price} each - Total: #{total_price}"
    end
  end
end
