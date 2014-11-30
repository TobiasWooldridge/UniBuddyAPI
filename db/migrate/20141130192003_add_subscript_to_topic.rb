class AddSubscriptToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :subscript, :string
  end
end
