class OrderBookSerializer < ActiveModel::Serializer
  attributes :buy_orders, :sale_orders
end
