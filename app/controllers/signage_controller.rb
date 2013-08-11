class SignageController < ApplicationController
  layout "signage"
  
  def view
    @building = Building.find(params[:id])
    @term_date = TermDates.current_week
  end

  def bookings
    @building = Building.find(params[:id])
    @empty_rooms = @building.empty_rooms
    @upcoming_usages = @building.upcoming_bookings
    @current_usages = @building.current_bookings

    render :layout => false
  end

  def news
    @latest = BlogPost.last

    render :layout => false
  end
end