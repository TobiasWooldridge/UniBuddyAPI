class RenameTermDatesFields < ActiveRecord::Migration
  def up
  	rename_column :term_dates, :start, :starts_at
  	rename_column :term_dates, :end, :ends_at
  end

  def down
  	rename_column :term_dates, :starts_at, :start
  	rename_column :term_dates, :ends_at, :end
  end
end
