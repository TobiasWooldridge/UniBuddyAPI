class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :message
      t.datetime :show_from
      t.datetime :show_until
      t.string :author_name

      t.timestamps
    end
  end
end
