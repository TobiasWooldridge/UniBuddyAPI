require 'test_helper'

class RoomBookingsControllerTest < ActionController::TestCase
  setup do
    @room_booking = room_bookings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:room_bookings)
  end
end
