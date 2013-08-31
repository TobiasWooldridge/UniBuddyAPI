class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    create_table :rooms do |t|
      t.string :code
      t.string :name
      t.integer :capacity
      t.references :building

      t.timestamps
    end
    
    create_table :room_bookings do |t|
      t.timestamp :starts_at
      t.timestamp :ends_at
      t.text :description
      t.boolean :cancelled
      t.references :room
      t.string :booked_for
      t.string :type

      t.timestamps
    end

    create_table :broadcasts do |t|
      t.string :message
      t.datetime :show_from
      t.datetime :show_until
      t.string :author_name

      t.timestamps
    end

    create_table :broadcasts_buildings, :id => false do |t|
      t.integer :broadcast_id
      t.integer :building_id
    end

    create_table :blog_posts do |t|
      t.integer :remote_id
      t.string :url
      t.string :title
      t.text :content
      t.datetime :published
      t.datetime :last_modified

      t.timestamps
    end

    create_table :term_dates do |t|
      t.timestamp :starts_at
      t.timestamp :ends_at
      t.string :semester
      t.string :week

      t.timestamps
    end
  end
end
