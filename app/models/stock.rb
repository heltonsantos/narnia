class Stock < ApplicationRecord
  belongs_to :wallet
  has_one :client, through: :wallet

  validates :uuid, :kind, :status, presence: true

  aasm column: :status do
    state :available, initial: true
    state :locked

    event :lock do
      transitions from: :available, to: :locked
    end

    event :available do
      transitions from: :lock, to: :available
    end
  end
end
