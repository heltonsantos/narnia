module Orders
  class SameClientError < StandardError
    def message
      'Order cannot be executed for the same client.'
    end
  end
end
