class ClientPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.user_id == user.id || user.admin?
  end

  def create?
    true
  end

  def update?
    record.user_id == user.id || user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
