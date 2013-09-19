class BlogPlaintext < ActiveRecord::Migration
  def change
    add_column :blog_posts, :plaintext, :text
  end
end
