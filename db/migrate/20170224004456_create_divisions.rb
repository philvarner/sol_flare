class CreateDivisions < ActiveRecord::Migration[5.0]
  def change
    create_table :divisions do |t|
      t.string :name, null: false  # e.g., Charlottesville City Public Schools, etc
    end

    add_index :divisions, [:name], :unique => true
  end
end
