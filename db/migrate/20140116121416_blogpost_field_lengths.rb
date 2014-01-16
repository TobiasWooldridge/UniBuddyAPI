class BlogpostFieldLengths < ActiveRecord::Migration
  def change
    change_column :blog_posts, :image, :text, :limit => 1024
    change_column :blog_posts, :url, :text, :limit => 1024
  end
end
