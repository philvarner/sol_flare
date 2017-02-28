class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string :name, null: false  # e.g., Lunenburg Middle, etc
      t.integer :school_id, null: false
      t.integer :division_id, null: false
    end

    add_index :schools, [:school_id, :division_id], :unique => true
    add_foreign_key :schools, :divisions

  end
end
