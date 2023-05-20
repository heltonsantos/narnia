module Stocks
  class Transfer
    def initialize(stocks:, wallet:)
      @stocks = stocks
      @current_order = stocks.first.order
      @current_wallet = stocks.first.wallet
      @new_wallet = wallet
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      ActiveRecord::Base.transaction do
        stocks.each do |stock|
          stock.wallet = new_wallet
          stock.order = nil
          stock.timelines.create!(timline_params)
          stock.available!
        end
      end
    end

    private

    attr_reader :stocks, :current_order, :current_wallet, :new_wallet

    def timline_params
      {
        action: 'stock_transferred',
        description: "Stock transferred from #{current_wallet.client.name} to #{new_wallet.client.name} by order #{current_order.uuid}"
      }
    end
  end
end
