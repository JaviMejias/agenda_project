class IncidentsController < ApplicationController
  before_action :set_property
  before_action :set_incident, only: [ :edit, :update, :destroy ]

  def create
    @incident = @property.incidents.build(incident_params)

    if @incident.save
      redirect_to @property, notice: "Incidencia reportada con éxito."
    else
      redirect_to @property, alert: "No se pudo reportar la incidencia: #{@incident.errors.full_messages.to_sentence}"
    end
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      redirect_to @property, notice: "Incidencia actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @incident.destroy
    redirect_to @property, notice: "Incidencia eliminada."
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_incident
    @incident = @property.incidents.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:title, :description, :status, :severity, :reservation_id, :photo)
  end
end
