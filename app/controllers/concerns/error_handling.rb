module ErrorHandling
  extend ActiveSupport::Concern

  def record_not_found_error(exception)
    render json: { error: exception.message }.to_json, status: :not_found
  end

  def record_invalid_error(exception)
    render json: { error: exception.message }.to_json, status: :unprocessable_entity
  end

  def enough_balance_error(exception)
    render json: { error: exception.message }.to_json, status: :unprocessable_entity
  end

  def enough_stock_error(exception)
    render json: { error: exception.message }.to_json, status: :unprocessable_entity
  end

  def internal_server_error(exception)
    render json: { error: exception.message }.to_json, status: :internal_server_error
  end

  def invalid_stock_kind_error(exception)
    render json: { error: exception.message }.to_json, status: :unprocessable_entity
  end
end
