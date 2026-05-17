class PaymentsController < ApplicationController
  before_action :set_reservation
  before_action :set_payment, only: [ :edit, :update, :destroy ]

  def new
    @payment = @reservation.payments.build
    authorize @payment
  end

  def edit
    authorize @payment
  end

  def create
    @payment = @reservation.payments.build(payment_params)
    authorize @payment

    if @payment.save
      redirect_to reservation_path(@reservation), notice: "Transacción registrada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @payment

    if @payment.update(payment_params)
      redirect_to reservation_path(@reservation), notice: "Transacción actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @payment
    @payment.destroy
    redirect_to reservation_path(@reservation), notice: "Transacción eliminada exitosamente."
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:reservation_id])
  end

  def set_payment
    @payment = @reservation.payments.find(params[:id])
  end

  def payment_params
    p = params.require(:payment).permit(:amount, :payment_date, :payment_method, :transaction_type, :notes, :operation_number, :voucher, :purge_voucher)
    if p[:amount].present? && p[:amount].is_a?(String)
      p[:amount] = p[:amount].gsub(".", "").gsub(",", ".")
    end
    p
  end
end
