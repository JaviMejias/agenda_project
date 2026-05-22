class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    authorize User
    @users = User.search(params[:q]).ordered.includes(:reservations).by_type(params[:type])
    @pagy, @users = pagy(@users, limit: 10)
  end

  def new
    authorize User
    @user = User.new
  end

  def show
    authorize @user
    redirect_to edit_user_path(@user)
  end

  def edit
    authorize @user
  end

  def create
    authorize User
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @user

    if @user.update(user_params_for_update)
      redirect_to users_path(type: @user.client? ? 'client' : nil), notice: "Usuario actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    if @user == current_user
      redirect_to users_path(type: @user.client? ? 'client' : nil), alert: "No puedes eliminarte a ti mismo."
    else
      @user.destroy
      redirect_to users_path(type: @user.client? ? 'client' : nil), notice: "Usuario eliminado exitosamente."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = [ :email, :password, :password_confirmation, :first_name, :last_name, :rut, :phone ]
    permitted << :role if current_user.admin?
    params.require(:user).permit(permitted)
  end

  def user_params_for_update
    if user_params[:password].blank?
      user_params.except(:password, :password_confirmation)
    else
      user_params
    end
  end
end
