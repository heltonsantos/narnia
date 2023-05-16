FactoryBot.define do
  factory :transaction do
    uuid { SecureRandom.uuid }
    type { 'StocksPurchaseTransaction' }
    nature { :outflow }
    value { 9.99 }
    description { 'Vibranium stocks purchase' }
    wallet { create(:wallet) }
  end
end
