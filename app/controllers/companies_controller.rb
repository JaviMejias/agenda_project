class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy associate_properties ]

  def index
    authorize Company
    @companies = Company.search(params[:q]).ordered
    @pagy, @companies = pagy(@companies, limit: 10)
  end

  def show
    authorize @company
    @pagy, @properties = pagy(@company.properties.order(created_at: :desc), limit: 8)
  end

  def new
    authorize Company
    @company = Company.new
  end

  def edit
    authorize @company
  end

  def create
    authorize Company
    @company = Company.new(company_params)
    @company.user = current_user

    if @company.save
      redirect_to companies_path, notice: "Empresa creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @company
    if @company.update(company_params)
      redirect_to companies_path, notice: "Empresa actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @company
    @company.destroy
    redirect_to companies_path, notice: "Empresa eliminada exitosamente.", status: :see_other
  end

  def associate_properties
    authorize @company
    property_ids = params[:property_ids] || []
    if @company.associate_properties(property_ids)
      @notice = "Propiedades vinculadas exitosamente."
    else
      @notice = "No se seleccionaron propiedades para vincular o hubo un error."
    end

    @pagy, @properties = pagy(@company.properties.order(created_at: :desc), limit: 8)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @company, notice: @notice }
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :rut, :business_type, :address)
  end
end
