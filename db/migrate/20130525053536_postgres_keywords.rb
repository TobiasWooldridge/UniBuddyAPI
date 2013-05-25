class PostgresKeywords < ActiveRecord::Migration
  def up
  	rename_column :room_bookings, :start, :starts_at
  	rename_column :room_bookings, :end, :ends_at
  end

  def down
  	rename_column :room_bookings, :starts_at, :start
  	rename_column :room_bookings, :ends_at, :end
  end
end
