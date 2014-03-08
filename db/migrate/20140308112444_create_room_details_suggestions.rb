class CreateRoomDetailsSuggestions < ActiveRecord::Migration
  def change
    create_table :room_details_suggestions do |t|
      t.references :room, index: true
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
