class AddTopicCodeColumn < ActiveRecord::Migration
  def change
    add_column :topics, :code, :string
  end
end
