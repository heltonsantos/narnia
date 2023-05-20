FactoryBot.define do
  factory :stocks_buy_transaction do
    uuid { SecureRandom.uuid }
    type { 'StocksBuyTransaction' }
    nature { :outflow }
    value { 9.99 }
    description { 'Vibranium stocks buy' }
    wallet { create(:wallet) }
  end
end
