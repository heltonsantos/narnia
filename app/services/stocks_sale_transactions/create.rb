module StocksSaleTransactions
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
      wallet.with_lock do
        StocksSaleTransactions.create!(
          wallet_id: wallet.id,
          value: value,
          description: description
        )
      end
    end

    private

    attr_reader :wallet, :value, :description
  end
end
