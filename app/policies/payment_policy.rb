class PaymentPolicy < ApplicationPolicy
  def create?
    record.reservation.user_id == user.id || user.admin?
  end

  def update?
    record.reservation.user_id == user.id || user.admin?
  end

  def destroy?
    record.reservation.user_id == user.id || user.admin?
  end

  def approve?
    update?
  end

  def reject?
    update?
  end
end
