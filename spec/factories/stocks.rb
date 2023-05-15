FactoryBot.define do
  factory :stock do |f|
    f.wallet { create(:wallet) }
    f.uuid { SecureRandom.uuid }
    f.kind { 'Vibranium' }
    f.status { 'available' }
  end
end
