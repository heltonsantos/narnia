class Wallet < ApplicationRecord
  belongs_to :client
  has_many :stocks, dependent: :destroy

  validates :client_id, :balance, presence: true
end
