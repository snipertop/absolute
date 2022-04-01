class StudentUserController < ApplicationController
  include StudentUserHelper
  def index
    StudentUserHelper.jdy_student_user_sync
  end
end
