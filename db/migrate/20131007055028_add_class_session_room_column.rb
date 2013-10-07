class AddClassSessionRoomColumn < ActiveRecord::Migration
  def change
    add_column :class_sessions, :room_id, :integer
    add_index  :class_sessions, :room_id
  end
end