require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get agenda_path
    assert_response :success
  end
end
