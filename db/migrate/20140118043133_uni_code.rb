class UniCode < ActiveRecord::Migration
  def change
    add_column :institutions, :code, :string, :limit => 10, :unique => true

    add_index :institutions, :name, :unique => true
    add_index :institutions, :nickname, :unique => true

    add_index :topics, [:year, :semester]
    add_index :topics, [:subject_area, :topic_number]
  end
end
