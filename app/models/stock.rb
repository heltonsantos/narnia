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
    state :on_sale

    event :sale do
      transitions from: :available, to: :on_sale
    end

    event :available do
      transitions from: :on_sale, to: :available
    end
  end

  scope :stocks_on_sale, ->(kind) { on_sale.where(kind: kind) }
end
