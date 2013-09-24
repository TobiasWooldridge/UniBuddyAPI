class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.string :subject_area, limit: 4
      t.string :topic_number, limit: 5
      t.integer :year
      t.string :semester, limit: 3
      t.decimal :units, :precision => 4, :scale => 1
      t.string :coordinator
      t.text :description
      t.text :aims
      t.text :learning_outcomes
      t.text :assumed_knowledge
      t.text :assessment
      t.string :class_contact
      t.string :text
      t.date :enrolment_opens
      t.string :enrolment_closes
      t.string :date
      t.date :census
      t.date :withdraw_no_fail_by

      t.timestamps
    end
  end
end
