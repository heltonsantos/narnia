module SaleOrders
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
      raise Wallets::EnoughStocksError unless enough_stocks?

      ActiveRecord::Base.transaction do
        SaleOrder.create!(
          uuid: SecureRandom.uuid,
          unit_price: unit_price,
          quantity: quantity,
          client_id: client.id,
          stocks: lock_stocks_for_sale_and_return
        )
      end
    end

    private

    attr_reader :client, :stock_kind, :unit_price, :quantity

    def enough_stocks?
      available_stocks.count >= quantity
    end

    def available_stocks
      @available_stocks ||= client.wallet.available_stocks(stock_kind)
    end

    def lock_stocks_for_sale_and_return
      stocks = available_stocks.first(quantity)
      stocks.each(&:sale!)

      stocks
    end
  end
end
