require "test_helper"

class ModifyMobilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @modify_mobile = modify_mobiles(:one)
  end

  test "should get index" do
    get modify_mobiles_url
    assert_response :success
  end

  test "should get new" do
    get new_modify_mobile_url
    assert_response :success
  end

  test "should create modify_mobile" do
    assert_difference("ModifyMobile.count") do
      post modify_mobiles_url, params: { modify_mobile: { idnumber: @modify_mobile.idnumber, mobile: @modify_mobile.mobile, name: @modify_mobile.name, reviewer: @modify_mobile.reviewer, status: @modify_mobile.status, userid: @modify_mobile.userid } }
    end

    assert_redirected_to modify_mobile_url(ModifyMobile.last)
  end

  test "should show modify_mobile" do
    get modify_mobile_url(@modify_mobile)
    assert_response :success
  end

  test "should get edit" do
    get edit_modify_mobile_url(@modify_mobile)
    assert_response :success
  end

  test "should update modify_mobile" do
    patch modify_mobile_url(@modify_mobile), params: { modify_mobile: { idnumber: @modify_mobile.idnumber, mobile: @modify_mobile.mobile, name: @modify_mobile.name, reviewer: @modify_mobile.reviewer, status: @modify_mobile.status, userid: @modify_mobile.userid } }
    assert_redirected_to modify_mobile_url(@modify_mobile)
  end

  test "should destroy modify_mobile" do
    assert_difference("ModifyMobile.count", -1) do
      delete modify_mobile_url(@modify_mobile)
    end

    assert_redirected_to modify_mobiles_url
  end
end
