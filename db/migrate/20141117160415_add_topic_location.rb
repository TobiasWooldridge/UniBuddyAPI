class AddTopicLocation < ActiveRecord::Migration
  def change
  	add_column :topics, :location, :string
  end
end
