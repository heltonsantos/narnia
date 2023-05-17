module StocksPurchaseTransactions
  class Create
    def initialize(wallet:, value:, description:)
      @wallet = wallet
      @value = value.abs
      @description = description
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      raise Wallets::EnoughBalanceError unless enough_balance?

      wallet.with_lock do
        StocksPurchaseTransaction.create!(
          wallet_id: wallet.id,
          value: value,
          description: description
        )
      end
    end

    private

    attr_reader :wallet, :value, :description

    def enough_balance?
      wallet.balance >= value
    end
  end
end
