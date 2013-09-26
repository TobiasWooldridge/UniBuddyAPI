class RemoveStrangeTextColumn < ActiveRecord::Migration
  def change
    # Seriously I have no idea what this column does
    # Maybe I'll add it back one day
    remove_column :topics, :text
  end
end
