class Order < ApplicationRecord
  include AASM

  has_many :stocks

  belongs_to :client

  validates :uuid, :type, :status, :unit_price, :quantity, presence: true

  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :completed
    state :partial_completed
    state :failed

    event :process do
      transitions from: :pending, to: :processing
    end

    event :complete do
      transitions from: [:processing, :partial_completed], to: :completed
    end

    event :partial_complete do
      transitions from: :processing, to: :partial_completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end
