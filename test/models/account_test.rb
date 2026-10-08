require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include SyncableInterfaceTest, EntriesTestHelper

  setup do
    @account = @syncable = accounts(:depository)
    @family = families(:dylan_family)
  end

  test "can destroy" do
    assert_difference "Account.count", -1 do
      @account.destroy
    end
  end

  test "gets short/long subtype label" do
    account = @family.accounts.create!(
      name: "Test Investment",
      balance: 1000,
      currency: "USD",
      subtype: "etf",
      accountable: Investment.new
    )

    assert_equal "ETF", account.short_subtype_label
    assert_equal "ETF", account.long_subtype_label

    # Test with nil subtype
    account.update!(subtype: nil)
    assert_equal "Investimenti", account.short_subtype_label
    assert_equal "Investimenti", account.long_subtype_label
  end
end
