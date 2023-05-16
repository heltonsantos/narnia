class Order < ApplicationRecord
  include AASM

  has_many :stocks, dependent: nil

  belongs_to :client

  validates :uuid, :type, :status, :unit_price, :quantity, :stock_kind, :expired_at, presence: true

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

  validate :validate_stock_kind

  private

  def validate_stock_kind
    errors.add(:stock_kind, 'is invalid') unless Stock.kinds.include?(stock_kind)
  end
end
