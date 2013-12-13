class RemoveBroadcasts < ActiveRecord::Migration
  def change
    drop_table :broadcasts
  end
end
