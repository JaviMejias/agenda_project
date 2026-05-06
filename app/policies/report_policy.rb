class ReportPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
