class CreateDemographics < ActiveRecord::Migration[5.0]
  def change
    create_table :demographics do |t|
      t.integer :school_id, null: false
      t.integer :division_id, null: false
      t.string :school_year, null: false
      t.string :grade, null: false
      t.integer :category, null: false
      t.integer :count, null: false
    end

    add_index :demographics, [:school_id,:division_id,:school_year,:grade,:category], :unique => true, :name => "demographics_all"

    add_foreign_key :demographics, :schools, column: :school_id, primary_key: :school_id
    add_foreign_key :demographics, :divisions

  end
end
