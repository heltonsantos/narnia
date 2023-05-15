FactoryBot.define do
  factory :transaction do
    uuid { SecureRandom.uuid }
    nature { :inflow }
    category { :stock_purchase }
    value { 9.99 }
    description { 'Stock purchase of Vibranium' }
    wallet { create(:wallet) }
  end
end
