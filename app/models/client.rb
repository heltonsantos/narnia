class Client < ApplicationRecord
  has_one :wallet, dependent: :destroy
  has_many :stocks, through: :wallet

  validates :uuid, :name, presence: true

  validates :uuid, uniqueness: true
end
