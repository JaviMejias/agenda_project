require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with correct attributes" do
    user = User.new(
      email: "test_new@example.com",
      password: "password123",
      first_name: "Juan",
      last_name: "Perez",
      rut: "12345678-5",
      phone: "+56912345678"
    )
    assert user.valid?
  end

  test "should return full_name" do
    user = users(:one)
    assert_equal "Juan Perez", user.full_name
  end

  test "search scope should find user by email or name" do
    user = users(:admin)
    results = User.search("admin")
    assert_includes results, user

    results = User.search("Admin") # Case insensitive
    assert_includes results, user
  end
end
