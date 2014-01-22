class CreateInstitutionSemesters < ActiveRecord::Migration
  def change
    create_table :institution_semesters do |t|
      t.references :institution, index: true

      t.integer :year
      t.string :code, limit: 5
      t.string :name, limit: 20
      t.integer :sort_order
      t.integer :group_key

      t.timestamps
    end
  end
end
