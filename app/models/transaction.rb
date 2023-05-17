class Transaction < ApplicationRecord
  belongs_to :wallet

  validates :uuid, :type, :nature, :value, presence: true

  enum nature: { outflow: 0, inflow: 1 }

  before_validation :set_nature
  before_validation :ensure_value

  after_save :update_wallet_balance

  private

  def set_nature
  end

  def ensure_value
    return if value.nil?

    if outflow?
      self.value = -value.abs
    elsif inflow?
      self.value = value.abs
    end
  end

  def update_wallet_balance
    wallet.update!(balance: wallet.balance + value)
  end
end
