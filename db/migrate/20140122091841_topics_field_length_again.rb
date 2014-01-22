class TopicsFieldLengthAgain < ActiveRecord::Migration
  def change
    change_column :topics, :topic_number, :string, :limit => 15
  end
end
