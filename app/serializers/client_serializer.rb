class ClientSerializer < ActiveModel::Serializer
  attributes :uuid, :name, :balance, :stocks_summary, :orders_summary, :transactions_summary

  def balance
    object.wallet.balance
  end

  def stocks_summary
    object.stocks.group(:kind, :status).count.transform_keys { |k| k.join('.') }
  end

  def orders_summary
    object.orders.group(:status).count
  end

  def transactions_summary
    object.transactions.group(:nature).count
  end
end
