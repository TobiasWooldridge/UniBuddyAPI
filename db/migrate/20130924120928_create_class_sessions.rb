class CreateClassSessions < ActiveRecord::Migration
  def change
    create_table :class_sessions do |t|
      t.references :class_group, index: true
      t.date :first_day
      t.date :last_day
      t.integer :day_of_week, limit: 1
      t.integer :time_starts_at
      t.integer :time_ends_at

      t.timestamps
    end
  end
end
