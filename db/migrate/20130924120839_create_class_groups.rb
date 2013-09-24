class CreateClassGroups < ActiveRecord::Migration
  def change
    create_table :class_groups do |t|
      t.references :class_type, index: true
      t.integer :group_number
      t.string :note
      t.boolean :full

      t.timestamps
    end
  end
end
