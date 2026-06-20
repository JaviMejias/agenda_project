class OperationalTasksController < ApplicationController
  before_action :set_reservation
  before_action :set_operational_task, only: [ :update, :destroy ]

  def create
    @task = @reservation.operational_tasks.build(operational_task_params)
    if @task.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @reservation, notice: "Tarea operativa creada correctamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_operational_task_form", partial: "operational_tasks/form", locals: { reservation: @reservation, task: @task }) }
        format.html { redirect_to @reservation, alert: "No se pudo crear la tarea." }
      end
    end
  end

  def update
    if @task.update(operational_task_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @reservation, notice: "Tarea eliminada." }
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:reservation_id])
  end

  def set_operational_task
    @task = @reservation.operational_tasks.find(params[:id])
  end

  def operational_task_params
    params.require(:operational_task).permit(:name, :task_type, :is_completed)
  end
end
