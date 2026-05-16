class PropertiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: %i[ show edit update destroy destroy_image gallery ]

  def index
    authorize Property
    @properties = Property.with_attached_images.search(params[:q])
    @pagy, @properties = pagy(:offset, @properties, limit: 20)
  end

  def list
    authorize Property
    @properties = Property.available_for_selector(current_user, query: params[:q])
    render json: @properties.as_json(only: [ :id, :name ])
  end

  def show
    authorize @property
  end

  def gallery
    authorize @property
    render partial: "properties/gallery", locals: { property: @property }
  end

  def new
    authorize Property
    @property = current_user.properties.build
  end

  def edit
    authorize @property
  end

  def create
    authorize Property
    @property = current_user.properties.build(property_params)
    images = params.dig(:property, :images)&.reject(&:blank?)
    @property.images.attach(images) if images.present?

    respond_to do |format|
      if @property.save
        GeneratePropertyImagesJob.perform_later(@property.id)
        format.html { redirect_to properties_path, notice: "Propiedad creada exitosamente. [Ver Propiedad](/properties/#{@property.id})" }
        format.json { render :show, status: :created, location: @property }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: "No se pudo crear la propiedad. Revisa los errores del formulario." })
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @property
    images = params.dig(:property, :images)&.reject(&:blank?)

    respond_to do |format|
      if @property.update(property_params)
        @property.images.attach(images) if images.present?
        GeneratePropertyImagesJob.perform_later(@property.id)
        format.html { redirect_to properties_path, notice: "Propiedad actualizada correctamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @property }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: "No se pudo actualizar la propiedad. Revisa los errores del formulario." })
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @property
    respond_to do |format|
      if @property.destroy
        format.html { redirect_to properties_path, notice: "Propiedad eliminada correctamente.", status: :see_other }
        format.json { head :no_content }
      else
        message = @property.errors.full_messages.to_sentence.presence || "No se pudo eliminar la propiedad."
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: message })
        end
        format.html { redirect_to properties_path, alert: message, status: :see_other }
      end
    end
  end

  def destroy_image
    authorize @property
    @image = @property.images.find(params[:image_id])

    respond_to do |format|
      begin
        @image.purge
        format.html { redirect_to edit_property_path(@property), notice: "Imagen eliminada correctamente." }
      rescue => e
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: "No se pudo eliminar la imagen." })
        end
        format.html { redirect_to edit_property_path(@property), alert: "No se pudo eliminar la imagen." }
      end
    end
  end

  private

  def set_property
    @property = Property.with_attached_images.find(params[:id])
  end

  def property_params
    params.require(:property).permit(:name, :description, :base_price, :pricing_model, :color, :address, :company_id)
  end
end
