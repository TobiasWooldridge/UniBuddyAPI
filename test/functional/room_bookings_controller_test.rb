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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create room_booking" do
    assert_difference('RoomBooking.count') do
      post :create, room_booking: { booked_for: @room_booking.booked_for, cancelled: @room_booking.cancelled, description: @room_booking.description, end: @room_booking.end, start: @room_booking.start, type: @room_booking.type }
    end

    assert_redirected_to room_booking_path(assigns(:room_booking))
  end

  test "should show room_booking" do
    get :show, id: @room_booking
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @room_booking
    assert_response :success
  end

  test "should update room_booking" do
    put :update, id: @room_booking, room_booking: { booked_for: @room_booking.booked_for, cancelled: @room_booking.cancelled, description: @room_booking.description, end: @room_booking.end, start: @room_booking.start, type: @room_booking.type }
    assert_redirected_to room_booking_path(assigns(:room_booking))
  end

  test "should destroy room_booking" do
    assert_difference('RoomBooking.count', -1) do
      delete :destroy, id: @room_booking
    end

    assert_redirected_to room_bookings_path
  end
end
