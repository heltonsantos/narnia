module Wallets
  class EnoughBalanceError < StandardError
    def message
      'The wallet does not have enough balance to complete the transaction.'
    end
  end
end
