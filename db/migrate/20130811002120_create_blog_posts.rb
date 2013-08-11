class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.integer :remote_id
      t.string :url
      t.string :title
      t.text :content
      t.datetime :published
      t.datetime :last_modified

      t.timestamps
    end
  end
end
