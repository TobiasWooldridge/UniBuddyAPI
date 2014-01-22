class TopicsFieldLengths < ActiveRecord::Migration
  def change
    change_column :topics, :subject_area, :string, :limit => 10
    change_column :topics, :semester, :string, :limit => 5
    change_column :topics, :topic_number, :string, :limit => 8
  end
end
