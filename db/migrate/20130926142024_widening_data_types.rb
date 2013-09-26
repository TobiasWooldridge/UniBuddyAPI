class WideningDataTypes < ActiveRecord::Migration
  def change
    change_column :topics, :class_contact, :text
  end
end
