class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name, :limit => 50
      t.string :nickname, :limit => 10
      t.string :country, :limit => 20
      t.string :state, :limit => 3

      t.timestamps
    end

    add_reference :buildings, :institution, index: true
    add_reference :topics, :institution, index: true
    add_reference :blog_posts, :institution, index: true
    add_reference :term_dates, :institution, index: true
  end
end