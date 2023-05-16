FactoryBot.define do
  factory :stocks_sale_transaction do
    uuid { SecureRandom.uuid }
    type { 'StocksSaleTransaction' }
    nature { :inflow }
    value { 9.99 }
    description { 'Vibranium stocks sale' }
    wallet { create(:wallet) }
  end
end
