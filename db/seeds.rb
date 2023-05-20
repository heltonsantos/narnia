require 'faker'

if Rails.env.development? && Client.count.zero?
  10.times do |i|
    client = Client.create!(
      uuid: SecureRandom.uuid,
      name: Faker::Name.name
    )

    wallet = Wallet.create!(
      balance: Faker::Number.decimal(l_digits: 3),
      client_id: client.id
    )

    100.times do |j|
      Stock.create!(
        uuid: SecureRandom.uuid,
        kind: :vibranium,
        status: :available,
        wallet_id: wallet.id
      )
    end
  end
end
