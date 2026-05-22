class ReservationPolicy < ApplicationPolicy
  def index?
    true
  end

  def list?
    true
  end

  def calendar_list?
    true
  end

  def show?
    user.admin? || user.normal?
  end

  def create?
    true
  end

  def update?
    user.admin? || user.normal?
  end

  def destroy?
    user.admin?
  end

  def view_timeline?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.normal?
        scope.all
      else
        scope.none
      end
    end
  end
end
