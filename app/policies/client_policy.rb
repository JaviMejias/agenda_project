class ClientPolicy < ApplicationPolicy
  def index?
    !user.client?
  end

  def show?
    !user.client?
  end

  def create?
    !user.client?
  end

  def update?
    !user.client? && (record.user_id == user.id || user.admin?)
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.client?
        scope.none
      else
        scope.all
      end
    end
  end
end
