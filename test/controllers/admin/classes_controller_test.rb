require "test_helper"

class Admin::ClassesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_classes_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_classes_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_classes_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_classes_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_classes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_classes_destroy_url
    assert_response :success
  end
end
