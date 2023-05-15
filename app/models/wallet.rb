class Wallet < ApplicationRecord
  belongs_to :client

  validates :client_id, :balance, presence: true
  validates :client_id, uniqueness: true
end
