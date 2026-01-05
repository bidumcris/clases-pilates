require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get show" do
    get agenda_path
    assert_response :success
  end
end
