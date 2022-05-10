require "application_system_test_case"

class ModifyMobilesTest < ApplicationSystemTestCase
  setup do
    @modify_mobile = modify_mobiles(:one)
  end

  test "visiting the index" do
    visit modify_mobiles_url
    assert_selector "h1", text: "Modify mobiles"
  end

  test "should create modify mobile" do
    visit modify_mobiles_url
    click_on "New modify mobile"

    fill_in "Idnumber", with: @modify_mobile.idnumber
    fill_in "Mobile", with: @modify_mobile.mobile
    fill_in "Name", with: @modify_mobile.name
    fill_in "Reviewer", with: @modify_mobile.reviewer
    fill_in "Status", with: @modify_mobile.status
    fill_in "Userid", with: @modify_mobile.userid
    click_on "Create Modify mobile"

    assert_text "Modify mobile was successfully created"
    click_on "Back"
  end

  test "should update Modify mobile" do
    visit modify_mobile_url(@modify_mobile)
    click_on "Edit this modify mobile", match: :first

    fill_in "Idnumber", with: @modify_mobile.idnumber
    fill_in "Mobile", with: @modify_mobile.mobile
    fill_in "Name", with: @modify_mobile.name
    fill_in "Reviewer", with: @modify_mobile.reviewer
    fill_in "Status", with: @modify_mobile.status
    fill_in "Userid", with: @modify_mobile.userid
    click_on "Update Modify mobile"

    assert_text "Modify mobile was successfully updated"
    click_on "Back"
  end

  test "should destroy Modify mobile" do
    visit modify_mobile_url(@modify_mobile)
    click_on "Destroy this modify mobile", match: :first

    assert_text "Modify mobile was successfully destroyed"
  end
end
