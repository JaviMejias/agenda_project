require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  def setup
    @expense = expenses(:one)
  end

  test "should be valid" do
    assert @expense.valid?
  end

  test "should require amount" do
    @expense.amount = nil
    assert_not @expense.valid?
  end

  test "should require numerical amount greater than 0" do
    @expense.amount = 0
    assert_not @expense.valid?
  end

  test "should require expense_date" do
    @expense.expense_date = nil
    assert_not @expense.valid?
  end

  test "should belong to property" do
    assert_respond_to @expense, :property
    assert_instance_of Property, @expense.property
  end
end
