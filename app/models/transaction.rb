class Transaction < ApplicationRecord
  belongs_to :wallet

  validates :uuid, :type, :nature, :value, presence: true

  enum nature: { outflow: 0, inflow: 1 }
end
