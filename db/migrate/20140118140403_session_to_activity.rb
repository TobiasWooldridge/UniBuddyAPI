class SessionToActivity < ActiveRecord::Migration
  def change
    rename_table :class_sessions, :activities
  end
end
