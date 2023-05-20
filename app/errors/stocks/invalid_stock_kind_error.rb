module Stocks
  class InvalidStockKindError < StandardError
    def message
      'Stock kind is invalid.'
    end
  end
end
