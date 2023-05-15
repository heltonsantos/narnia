class Stock < ApplicationRecord
  belongs_to :wallet
  has_one :client, through: :wallet

  validates :uuid, :kind, :status, presence: true
end
