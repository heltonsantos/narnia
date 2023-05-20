class OrderSerializer < ActiveModel::Serializer
  attributes :id, :uuid, :type, :status, :unit_price, :quantity, :quantity_sold, :stock_kind, :error_message, :retry_count, :expired_at,
             :processing_at, :partial_completed_at, :completed_at, :failed_at, :retryed_at, :client_id, :created_at, :updated_at, :timelines

  def timelines
    object.timelines.order(:created_at).map do |timeline|
      {
        action: timeline.action,
        description: timeline.description,
        created_at: timeline.created_at
      }
    end
  end
end
