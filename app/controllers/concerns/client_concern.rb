module ClientConcern
  extend ActiveSupport::Concern

  private

  def client
    @client ||= Client.find_by!(uuid: params['client_uuid'])
  end
end
