class Client < ApplicationRecord
  validates :uuid, :name, presence: true

  validates :uuid, uniqueness: true
end
