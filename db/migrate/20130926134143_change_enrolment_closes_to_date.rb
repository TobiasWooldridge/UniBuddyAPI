class ChangeEnrolmentClosesToDate < ActiveRecord::Migration
  def change
    remove_column :topics, :enrolment_closes
    add_column :topics, :enrolment_closes, :date
  end
end
