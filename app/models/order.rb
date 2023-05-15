class Order < ApplicationRecord
  has_many :stocks

  belongs_to :client

  validates :uuid, :type, :status, :unit_price, :quantity, presence: true
end
