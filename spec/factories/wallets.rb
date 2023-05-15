FactoryBot.define do
  factory :wallet do |f|
    f.client { create(:client) }
    f.balance { Faker::Number.decimal(2) }
  end
end
