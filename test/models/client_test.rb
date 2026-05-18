require "test_helper"

class ClientTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with correct attributes" do
    # Use a RUT that is not in fixtures (123456785 and 186365291 are used)
    client = Client.new(
      name: "Pedro Marmol",
      rut: "15.147.321-0",
      user: @user
    )
    assert client.valid?
  end

  test "should be invalid without name" do
    client = Client.new(name: nil)
    assert_not client.valid?
    assert_includes client.errors[:name], "es obligatorio/a"
  end

  test "should be invalid with invalid RUT" do
    client = Client.new(rut: "111-1")
    assert_not client.valid?
    assert_includes client.errors[:rut], "no es válido/a"
  end

  test "should clean RUT before validation" do
    # 18.636.529-1 is valid
    client = Client.new(rut: "18.636.529-1", user: @user, name: "Test")
    client.valid?
    # The RUT is cleaned to numbers and K
    assert_equal "186365291", client.rut
  end

  test "display_name should include name and rut" do
    client = clients(:one)
    assert_match client.name, client.display_name
    assert_match client.formatted_rut, client.display_name
  end

  test "search scope should find client by name or rut" do
    results = Client.search("Diego")
    assert_includes results, clients(:one)

    # Use the current fixture RUT for Maria Lopez (two)
    results = Client.search("186365291")
    assert_includes results, clients(:two)
  end
end
