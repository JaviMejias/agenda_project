require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @normal = users(:one)
    @client_one = clients(:one)
  end

  test "should get global search results for admin" do
    sign_in @admin
    get search_url, params: { q: "Diego" }
    assert_response :success

    results = JSON.parse(response.body)["results"]
    assert_not_nil results
    assert results.any? { |r| r["category"] == "Clientes" && r["title"] == @client_one.name }
  end

  test "should get global search results for normal user" do
    sign_in @normal
    get search_url, params: { q: "Diego" }
    assert_response :success

    results = JSON.parse(response.body)["results"]
    assert_not_nil results
    assert results.any? { |r| r["category"] == "Clientes" && r["title"] == @client_one.name }
  end

  test "normal user should not get users in search results" do
    sign_in @normal
    get search_url, params: { q: "admin" }
    assert_response :success

    results = JSON.parse(response.body)["results"]
    assert_not_nil results
    assert results.none? { |r| r["category"] == "Usuarios" }
  end

  test "admin should get users in search results" do
    sign_in @admin
    get search_url, params: { q: "admin" }
    assert_response :success

    results = JSON.parse(response.body)["results"]
    assert_not_nil results
    assert results.any? { |r| r["category"] == "Usuarios" }
  end

  test "should return empty results if query is too short" do
    sign_in @admin
    get search_url, params: { q: "a" }
    assert_response :success

    results = JSON.parse(response.body)["results"]
    assert_empty results
  end
end
