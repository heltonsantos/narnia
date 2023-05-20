class Timeline < ApplicationRecord
  belongs_to :timelineref, polymorphic: true

  validates :action, :description, presence: true
end
