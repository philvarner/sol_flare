class CreateSolIds < ActiveRecord::Migration[5.0]
  def change
    # SOL score IDs (used for getting xls from state board)
    create_table :sol_ids do |t|
      t.integer :school_id, null: false
      t.integer :division_id, null: false
      t.integer :school_sol_id, null: false
    end

    add_index :sol_ids, [:school_id,:school_sol_id], :unique => true
    add_foreign_key :sol_ids, :schools

  end
end
