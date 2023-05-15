class Client < ApplicationRecord
  has_one :wallet, dependent: :destroy

  validates :uuid, :name, presence: true

  validates :uuid, uniqueness: true
end
