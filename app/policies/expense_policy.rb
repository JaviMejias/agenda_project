class ExpensePolicy < ApplicationPolicy
  def index?
    record.property.user_id == user.id || user.admin?
  end

  def create?
    record.property.user_id == user.id || user.admin?
  end

  def update?
    record.property.user_id == user.id || user.admin?
  end

  def destroy?
    record.property.user_id == user.id || user.admin?
  end
end
