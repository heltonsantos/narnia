module BuyOrders
  class Process
    def initialize(buy_order:)
      @buy_order = buy_order
      @wallet = @buy_order.client.wallet
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      buy_order.process! unless buy_order.processing?

      return reenqueue unless enough_stocks_on_sale?

      buy_order.with_lock do
        StocksBuyTransactions::Create.call!(wallet: wallet, value: total_price, description: description)

        buyed_stocks.group_by(&:order).each do |sale_order, stocks_to_sell|
          SaleOrders::Process.call!(sale_order: sale_order, buy_order: buy_order, stocks_to_sell: stocks_to_sell)
        end

        buy_order.stocks = buyed_stocks
        buy_order.complete!

        #transfer_stocks_to_client
      end
    end

    private

    attr_reader :buy_order, :wallet

    def stocks_on_sale
      @stocks_on_sale ||= Stock.stocks_on_sale(buy_order.stock_kind).where.not(wallet_id: wallet.id)
    end

    def enough_stocks_on_sale?
      stocks_on_sale.count >= buy_order.quantity
    end

    def reenqueue
      return buy_order.expire! if buy_order.expired_at < Date.current

      ProcessBuyOrderWorker.perform_in(10.minutes, buy_order.id)
    end

    def total_price
      @total_price ||= buy_order.unit_price * buy_order.quantity
    end

    def description
      "Buy order ##{buy_order.id} - #{buy_order.quantity} stocks of #{buy_order.stock_kind} " \
        "for #{buy_order.unit_price} each - Total: #{total_price}"
    end

    def buyed_stocks
      @buyed_stocks ||= stocks_on_sale.order(created_at: :asc).limit(buy_order.quantity)
    end
  end
end
