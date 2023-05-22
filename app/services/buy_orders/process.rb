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

      return buy_order.fail! if rached_retry_limit?
      return buy_order.expire! if expired?
      return enqueue_again unless enough_stocks_on_sale?

      buy_order.with_lock do
        StocksBuyTransactions::Create.call!(wallet: wallet, value: total_price, description: description)

        buyed_stocks.group_by(&:order).each do |sale_order, stocks_to_sell|
          SaleOrders::Process.call!(sale_order: sale_order, buy_order: buy_order, stocks_to_sell: stocks_to_sell)
        end

        buy_order.stocks = buyed_stocks
        buy_order.timelines.build(action: 'buy_order_processed', description: description)
        buy_order.complete!

        Stocks::Transfer.call!(stocks: buyed_stocks, wallet: wallet)

        buy_order
      end
    end

    private

    attr_reader :buy_order, :wallet

    def stocks_on_sale
      @stocks_on_sale ||= Stock.stocks_on_sale(buy_order.stock_kind).where.not(wallet_id: wallet.id)
    end

    def buyed_stocks
      @buyed_stocks ||= stocks_on_sale.order('order.created_at': :asc).limit(buy_order.quantity)
    end

    def total_price
      @total_price ||= buy_order.unit_price * buy_order.quantity
    end

    def rached_retry_limit?
      buy_order.retry_count >= Rails.configuration.narnia.process_buy_order_retry_limit.to_i
    end

    def expired?
      buy_order.expired_at < Date.current
    end

    def enough_stocks_on_sale?
      stocks_on_sale.count >= buy_order.quantity
    end

    def enqueue_again
      timeline_description = 'Buy order requeued by not enough stocks on sale'
      buy_order.timelines.create!(action: 'buy_order_requeued', description: timeline_description)

      ProcessBuyOrderWorker.perform_in(
        Rails.configuration.worker.process_buy_order_worker_enqueue_delay.to_i.minutes,
        buy_order.uuid
      )
    end

    def description
      "Buy order ##{buy_order.uuid} - #{buy_order.quantity} stocks of #{buy_order.stock_kind} " \
        "for #{buy_order.unit_price} each - Total: #{total_price}"
    end
  end
end
