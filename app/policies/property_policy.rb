class PropertyPolicy < ApplicationPolicy
  def index?
    true
  end

  def list?
    true
  end

  def show?
    true
  end

  def gallery?
    true
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def destroy_image?
    user.admin?
  end
end
