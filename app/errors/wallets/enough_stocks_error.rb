module Wallets
  class EnoughStocksError < StandardError
    def message
      'The wallet does not have enough stocks to complete the transaction.'
    end
  end
end
