class RenameSelectionSyncToStream < ActiveRecord::Migration
  def change
    rename_table :selection_syncs, :streams
    rename_column :class_groups, :synced_selections_id, :stream_id
  end
end
