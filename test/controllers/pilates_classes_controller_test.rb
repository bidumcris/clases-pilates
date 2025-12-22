require "test_helper"

class PilatesClassesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pilates_classes_index_url
    assert_response :success
  end

  test "should get show" do
    get pilates_classes_show_url
    assert_response :success
  end
end
