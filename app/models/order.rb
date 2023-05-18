class Order < ApplicationRecord
  has_paper_trail

  include AASM

  has_many :stocks, dependent: nil

  belongs_to :client

  validates :uuid, :type, :status, :unit_price, :quantity, :stock_kind, :expired_at, presence: true

  aasm column: :status do
    state :pending, initial: true
    state :processing
    state :completed
    state :partial_completed
    state :failed
    state :expired
    state :retrying

    event :process do
      transitions from: %i[pending partial_completed retrying], to: :processing, success: %i[set_processing_at clear_retry_fields]
    end

    event :complete do
      transitions from: %i[processing partial_completed], to: :completed, success: :set_completed_at
    end

    event :partial_complete do
      transitions from: :processing, to: :partial_completed, success: :set_partial_completed_at
    end

    event :fail do
      transitions from: %i[processing retrying], to: :failed, success: :set_failed_at
    end

    event :expire do
      transitions from: :processing, to: :expired, success: :set_expired_at
    end

    event :retry do
      transitions from: %i[pending processing], to: :retrying, success: :set_retryed_at
    end
  end

  validate :validate_stock_kind

  private

  def validate_stock_kind
    errors.add(:stock_kind, 'is invalid') unless Stock.kinds.include?(stock_kind)
  end

  def set_retryed_at
    update!(retryed_at: Time.zone.now)
  end

  def set_expired_at
    update!(expired_at: Time.zone.now)
  end

  def set_failed_at
    update!(failed_at: Time.zone.now)
  end

  def set_partial_completed_at
    update!(partial_completed_at: Time.zone.now)
  end

  def set_completed_at
    update!(completed_at: Time.zone.now)
  end

  def set_processing_at
    update!(processing_at: Time.zone.now)
  end

  def clear_retry_fields
    update!(retry_count: 0, error_message: nil)
  end
end
