module Stocks
  class Transfer
    def initialize(stocks:, wallet:)
      @stocks = stocks
      @wallet = wallet
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      ActiveRecord::Base.transaction do
        stocks.each do |stock|
          stock.wallet = wallet
          stock.available!
        end
      end
    end

    private

    attr_reader :stocks, :wallet
  end
end
