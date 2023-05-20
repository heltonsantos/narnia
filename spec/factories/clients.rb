FactoryBot.define do
  factory :client do |f|
    f.uuid { SecureRandom.uuid }
    f.name { Faker::Name.name }
  end
end
