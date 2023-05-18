class Stock < ApplicationRecord
  has_paper_trail

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
      transitions from: :available, to: :on_sale, success: :set_on_sale_at
    end

    event :available do
      transitions from: :on_sale, to: :available, success: :set_available_at
    end
  end

  scope :stocks_on_sale, ->(kind) { on_sale.where(kind: kind) }

  private

  def set_available_at
    update!(available_at: Time.zone.now)
  end

  def set_on_sale_at
    update!(on_sale_at: Time.zone.now)
  end
end
