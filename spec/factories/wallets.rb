FactoryBot.define do
  factory :wallet do |f|
    f.client { create(:client) }
    f.balance { Faker::Number.decimal(l_digits: 2) }
  end
end
