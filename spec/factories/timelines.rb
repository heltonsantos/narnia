FactoryBot.define do
  factory :timeline do |f|
    f.action { 'sale_order_created' }
    f.description { 'Sale order created' }
    f.timelineref { create(:sale_order) }
  end
end
