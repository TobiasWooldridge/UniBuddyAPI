class CreateTermDates < ActiveRecord::Migration
  def change
    create_table :term_dates do |t|
      t.timestamp :start
      t.timestamp :end
      t.string :semester
      t.string :week

      t.timestamps
    end
  end
end
