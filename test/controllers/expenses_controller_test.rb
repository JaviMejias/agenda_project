require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @property = properties(:one)
    @expense = expenses(:one)
    sign_in @user
  end

  test "should get index" do
    get property_expenses_url(@property)
    assert_response :success
  end

  test "should get new" do
    get new_property_expense_url(@property)
    assert_response :success
  end

  test "should create expense" do
    assert_difference("Expense.count") do
      post property_expenses_url(@property), params: {
        expense: {
          amount: 5000,
          category: "light",
          expense_date: Date.today,
          description: "Test expense"
        }
      }
    end

    assert_redirected_to property_expenses_url(@property)
  end

  test "should get edit" do
    get edit_property_expense_url(@property, @expense)
    assert_response :success
  end

  test "should update expense" do
    patch property_expense_url(@property, @expense), params: {
      expense: { amount: 6000 }
    }
    assert_redirected_to property_expenses_url(@property)
    @expense.reload
    assert_equal 6000, @expense.amount
  end

  test "should destroy expense" do
    assert_difference("Expense.count", -1) do
      delete property_expense_url(@property, @expense)
    end

    assert_redirected_to property_expenses_url(@property)
  end
end
