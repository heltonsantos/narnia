FactoryBot.define do
  factory :sale_order do
    uuid { SecureRandom.uuid }
    status { 'pending' }
    unit_price { '9.99' }
    quantity { 1 }
    stock_kind { 'vibranium' }
    client { create(:client) }
    stocks { create_list(:stock, 1) }
  end
end
