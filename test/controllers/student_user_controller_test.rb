require "test_helper"

class StudentUserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get student_user_index_url
    assert_response :success
  end
end
