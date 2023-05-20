FactoryBot.define do
  factory :timeline do |f|
    f.action { 'sale_order_processed' }
    f.description { 'Sale order processed' }
    f.timelineref { create(:sale_order) }
  end
end
