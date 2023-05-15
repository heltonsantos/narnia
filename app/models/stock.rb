class Stock < ApplicationRecord
  include AASM

  belongs_to :wallet
  belongs_to :order, optional: true

  has_one :client, through: :wallet

  validates :uuid, :kind, :status, presence: true
  validates :uuid, uniqueness: true

  enum kind: { vibranium: 0 }

  aasm column: :status do
    state :available, initial: true
    state :locked

    event :lock do
      transitions from: :available, to: :locked
    end

    event :available do
      transitions from: :locked, to: :available
    end
  end
end
