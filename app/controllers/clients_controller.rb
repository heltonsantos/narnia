class ClientsController < ApplicationController
  include ClientConcern

  before_action :client, only: :show

  def index
    render json: Client.all
  end

  def show
    render json: client
  end
end
