class AddUniqueTopicCode < ActiveRecord::Migration
  def change
    add_column :topics, :unique_topic_code, :string
    add_index  :topics, :unique_topic_code
  end
end
