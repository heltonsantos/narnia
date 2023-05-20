module OrderConcern
  extend ActiveSupport::Concern

  private

  def create_params
    params.permit(:client_uuid, :stock_kind, :unit_price, :quantity, :expired_at)
  end
end
