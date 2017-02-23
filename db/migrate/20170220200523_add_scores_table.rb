class AddScoresTable < ActiveRecord::Migration[5.0]
  def change

    create_table :districts do |t|
      t.string :name  # e.g., Charlottesville City Public Schools, etc
    end

    add_index :districts, [:name], :unique => true

   create_table :schools do |t|
      t.string :name  # e.g., Lunenburg Middle, etc
      t.integer :district_id 
    end

    add_index :schools, [:name], :unique => true
    add_foreign_key :schools, :districts

    create_table :scores do |t|
      t.integer :school_id  # schools.id
      t.string :school_year  # e.g., 2015-2016, etc.
      t.string :test_type    # e.g., Civics and Economics, Mathematics, English: Reading, etc. 
      t.string :grade       # e.g., Grade 4, Content Specific, etc.
      t.string :result_level # e.g., adv, pro, fai
      t.string :subgroup    # e.g., White, Black, Economically Disadvantaged, etc. 
      t.string :percentage  # 24, 100, - (no results), < (less than subgroup threshold for reporting), etc. 
      t.timestamps
    end

    add_index :scores, [:school_id, :school_year, :test_type, :grade, :result_level, :subgroup, :percentage], :unique => true, :name => 'scores_uniqueness_index'
    add_foreign_key :scores, :schools

  end
end
