FactoryBot.define do
  factory :order do
    uuid { SecureRandom.uuid }
    type { 'PurchaseOrder' }
    status { 'pending' }
    unit_price { '9.99' }
    quantity { 1 }
    client { create(:client) }
    stocks { create_list(:stock, 1) }
  end
end
