class BlogImageAndCaption < ActiveRecord::Migration
  def change
    add_column :blog_posts, :image, :string
    add_column :blog_posts, :caption, :string
  end
end
