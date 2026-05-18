class ExpensesController < ApplicationController
  before_action :set_property
  before_action :set_expense, only: [ :edit, :update, :destroy ]

  def index
    authorize Expense.new(property: @property), :index?
    @pagy, @expenses = pagy(:offset, @property.expenses.with_attached_vouchers.order(expense_date: :desc), limit: 15)
  end

  def new
    @expense = @property.expenses.build
    authorize @expense
  end

  def edit
    authorize @expense
  end

  def create
    @expense = @property.expenses.build(expense_params)
    authorize @expense

    if @expense.save
      redirect_to property_expenses_path(@property), notice: "Gasto registrado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @expense

    if @expense.update(expense_params)
      redirect_to property_expenses_path(@property), notice: "Gasto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @expense
    @expense.destroy
    redirect_to property_expenses_path(@property), notice: "Gasto eliminado exitosamente."
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_expense
    @expense = @property.expenses.find(params[:id])
  end

  def expense_params
    p = params.require(:expense).permit(:amount, :expense_date, :category, :description, vouchers: [])
    if p[:amount].present? && p[:amount].is_a?(String)
      p[:amount] = p[:amount].gsub(".", "").gsub(",", ".")
    end
    p
  end
end
