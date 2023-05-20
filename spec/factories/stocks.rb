FactoryBot.define do
  factory :stock do |f|
    f.wallet { create(:wallet) }
    f.uuid { SecureRandom.uuid }
    f.kind { :vibranium }
    f.status { 'available' }
  end
end
