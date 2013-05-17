class RoomBookingsController < ApplicationController
  # GET /room_bookings
  # GET /room_bookings.json
  def index
    @room_bookings = RoomBooking.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @room_bookings }
    end
  end

  # GET /room_bookings/1
  # GET /room_bookings/1.json
  def show
    @room_booking = RoomBooking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @room_booking }
    end
  end

  # GET /room_bookings/new
  # GET /room_bookings/new.json
  def new
    @room_booking = RoomBooking.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @room_booking }
    end
  end

  # GET /room_bookings/1/edit
  def edit
    @room_booking = RoomBooking.find(params[:id])
  end

  # POST /room_bookings
  # POST /room_bookings.json
  def create
    @room_booking = RoomBooking.new(params[:room_booking])

    respond_to do |format|
      if @room_booking.save
        format.html { redirect_to @room_booking, notice: 'Room booking was successfully created.' }
        format.json { render json: @room_booking, status: :created, location: @room_booking }
      else
        format.html { render action: "new" }
        format.json { render json: @room_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /room_bookings/1
  # PUT /room_bookings/1.json
  def update
    @room_booking = RoomBooking.find(params[:id])

    respond_to do |format|
      if @room_booking.update_attributes(params[:room_booking])
        format.html { redirect_to @room_booking, notice: 'Room booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room_booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /room_bookings/1
  # DELETE /room_bookings/1.json
  def destroy
    @room_booking = RoomBooking.find(params[:id])
    @room_booking.destroy

    respond_to do |format|
      format.html { redirect_to room_bookings_url }
      format.json { head :no_content }
    end
  end
end
