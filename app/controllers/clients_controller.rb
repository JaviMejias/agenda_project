class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[ show edit update ]

  def index
    @clients = Client.all.search(params[:q]).order(name: :asc)
    @pagy, @clients = pagy(@clients, limit: 15)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    authorize @client
    @reservations = @client.reservations.ordered
    @pagy, @reservations = pagy(@reservations, limit: 5)
  end

  def new
    @client = Client.new
    authorize @client
  end

  def edit
    authorize @client
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    authorize @client

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: "Cliente creado exitosamente.", status: :see_other }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @client
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to clients_path, notice: "Cliente actualizado.", status: :see_other }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @clients = Client.all.search(params[:q]).limit(20)
    render json: @clients.map { |c| { id: c.id, name: c.name, rut: c.rut } }
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :rut, :phone, :email)
  end
end
