require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  include Warden::Test::Helpers

  def login_as_user(user)
    login_as(user, scope: :user)
  end

  def teardown
    Warden.test_reset!
    super
  end
end
