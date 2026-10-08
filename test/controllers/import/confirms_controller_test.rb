require "test_helper"

class Import::ConfirmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
  end

  test "shows if cleaned" do
    import = imports(:transaction)

    TransactionImport.any_instance.stubs(:cleaned?).returns(true)

    get import_confirm_path(import)
    assert_response :success
  end

  test "redirects if not cleaned" do
    import = imports(:transaction)

    TransactionImport.any_instance.stubs(:cleaned?).returns(false)

    get import_confirm_path(import)
    assert_redirected_to import_clean_path(import)
    assert_equal "Hai dei dati non validi, modificali finché tutti gli errori non sono risolti", flash[:alert]
  end
end
