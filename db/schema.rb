# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170224004803) do

  create_table "demographics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "school_id",   null: false
    t.integer "division_id", null: false
    t.string  "school_year", null: false
    t.string  "grade",       null: false
    t.integer "category",    null: false
    t.integer "count",       null: false
    t.index ["division_id"], name: "fk_rails_febfe9bf18", using: :btree
    t.index ["school_id", "division_id", "school_year", "grade", "category"], name: "demographics_all", unique: true, using: :btree
  end

  create_table "divisions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_divisions_on_name", unique: true, using: :btree
  end

  create_table "schools", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "name",        null: false
    t.integer "school_id",   null: false
    t.integer "division_id", null: false
    t.index ["division_id"], name: "fk_rails_8f834018e1", using: :btree
    t.index ["school_id", "division_id"], name: "index_schools_on_school_id_and_division_id", unique: true, using: :btree
  end

  create_table "scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "school_id",    null: false
    t.integer  "division_id",  null: false
    t.string   "school_year",  null: false
    t.string   "test_type",    null: false
    t.string   "grade",        null: false
    t.integer  "result_level", null: false
    t.integer  "subgroup",     null: false
    t.string   "percentage",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["division_id"], name: "fk_rails_61e6719b2c", using: :btree
    t.index ["school_id", "division_id", "school_year", "test_type", "grade", "result_level", "subgroup", "percentage"], name: "scores_uniqueness_index", unique: true, using: :btree
  end

  create_table "sol_ids", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "school_id",     null: false
    t.integer "division_id",   null: false
    t.integer "school_sol_id", null: false
    t.index ["school_id", "school_sol_id"], name: "index_sol_ids_on_school_id_and_school_sol_id", unique: true, using: :btree
  end

  add_foreign_key "demographics", "divisions"
  add_foreign_key "demographics", "schools", primary_key: "school_id"
  add_foreign_key "schools", "divisions"
  add_foreign_key "scores", "divisions"
  add_foreign_key "scores", "schools", primary_key: "school_id"
  add_foreign_key "sol_ids", "schools"
end
