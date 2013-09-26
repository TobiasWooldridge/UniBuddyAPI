class RemoveStrangeDateColumn < ActiveRecord::Migration
  def change
    remove_column :topics, :date
  end
end
