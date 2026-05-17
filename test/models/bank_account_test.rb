require "test_helper"

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @bank_account = bank_accounts(:one)
  end

  test "should be valid with valid attributes" do
    assert @bank_account.valid?
  end

  test "should require company" do
    @bank_account.company = nil
    assert_not @bank_account.valid?
  end

  test "should require account_number" do
    @bank_account.account_number = nil
    assert_not @bank_account.valid?
  end

  test "should require holder_name" do
    @bank_account.holder_name = nil
    assert_not @bank_account.valid?
  end

  test "should require holder_rut" do
    @bank_account.holder_rut = nil
    assert_not @bank_account.valid?
  end

  test "should require holder_email" do
    @bank_account.holder_email = nil
    assert_not @bank_account.valid?
  end

  test "should clean and format RUT before validation" do
    @bank_account.holder_rut = "19.456.789-8"
    @bank_account.valid? # Triggers before_validation callback
    assert_equal "194567898", @bank_account.holder_rut
  end

  test "should accept a valid Chilean RUT" do
    @bank_account.holder_rut = "19.456.789-8"
    assert @bank_account.valid?
  end

  test "should reject an invalid Chilean RUT" do
    @bank_account.holder_rut = "19.456.789-9"
    assert_not @bank_account.valid?
    assert_includes @bank_account.errors[:holder_rut], I18n.t("activerecord.errors.models.bank_account.attributes.holder_rut.invalid", default: "no es válido/a")
  end

  test "should support localized bank name" do
    assert_equal I18n.t("enums.bank_account.bank_name.state_bank", default: "Banco Estado"), @bank_account.localized_bank_name
  end

  test "should support localized account type" do
    assert_equal I18n.t("enums.bank_account.account_type.checking", default: "Cuenta Corriente"), @bank_account.localized_account_type
  end
end
