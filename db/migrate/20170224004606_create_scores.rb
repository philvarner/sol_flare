class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.integer :school_id, null: false  # schools.id
      t.integer :division_id, null: false #divisions.id
      t.string :school_year, null: false  # e.g., 2015-2016, etc.
      t.string :test_type, null: false    # e.g., Civics and Economics, Mathematics, English: Reading, etc.
      t.string :grade, null: false       # e.g., Grade 4, Content Specific, etc.
      t.integer :result_level, null: false # e.g., adv = 2, pro = 1, fai = 0
      t.integer :subgroup, null: false    # e.g., numeric for White, Black, Economically Disadvantaged, etc.
      t.string :percentage, null: false  # 24, 100, - (no results), < (less than subgroup threshold for reporting), etc.
      t.timestamps
    end

    add_index :scores, [:school_id, :division_id, :school_year, :test_type, :grade, :result_level, :subgroup, :percentage], :unique => true, :name => 'scores_uniqueness_index'
    add_foreign_key :scores, :schools, column: :school_id, primary_key: :school_id

    add_foreign_key :scores, :divisions
  end
end
