ActiveRecord::Schema[8.0].define(version: 2025_08_07_165322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "challenges", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
