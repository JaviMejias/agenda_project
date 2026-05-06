require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  include Warden::Test::Helpers

  def login_as_user(user)
    login_as(user, scope: :user)
  end
end
