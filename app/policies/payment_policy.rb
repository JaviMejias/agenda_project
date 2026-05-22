class PaymentPolicy < ApplicationPolicy
  def create?
    user.admin? || user.normal?
  end

  def update?
    user.admin? || user.normal?
  end

  def destroy?
    user.admin? || user.normal?
  end

  def approve?
    update?
  end

  def reject?
    update?
  end
end
