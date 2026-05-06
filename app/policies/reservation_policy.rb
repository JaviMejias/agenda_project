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
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
