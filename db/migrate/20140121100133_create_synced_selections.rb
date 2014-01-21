class CreateSyncedSelections < ActiveRecord::Migration
  def change
    create_table :selection_syncs do |t|
      t.references :topic, index: true

      t.timestamps
    end

    add_column :class_groups, :synced_selections_id, :integer
    add_index :class_groups, :synced_selections_id
  end
end
