class SignageController < ApplicationController
  layout "signage"
  
  def view 
    @building = Building.where(:code => params[:building]).first

    @current_usages = @building.current_bookings
    @upcoming_usages = @building.upcoming_bookings

    now = Time.now
    @empty_rooms = Room.where(:building_id => @building).joins('LEFT OUTER JOIN room_bookings ON room_bookings.room_id = rooms.id AND room_bookings.starts_at <= now() AND room_bookings.ends_at > now()').where('room_bookings.id IS NULL')

    puts @empty_rooms.explain
  end
end


