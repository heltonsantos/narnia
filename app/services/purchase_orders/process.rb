module PurchaseOrders
  class Create
    def initialize(id:)
      @purchase_order = PurchaseOrder.find(id)
    end

    def self.call!(**args)
      new(args).call!
    end

    def call!
      true
    end

    private

    attr_reader :purchase_order
  end
end
