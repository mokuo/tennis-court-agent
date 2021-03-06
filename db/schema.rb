# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_09_105525) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availability_checks", force: :cascade do |t|
    t.string "identifier", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0
    t.index ["identifier"], name: "index_availability_checks_on_identifier", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "availability_check_identifier", null: false
    t.string "name", null: false
    t.datetime "published_at", null: false
    t.json "contents"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reservation_frames", force: :cascade do |t|
    t.string "availability_check_identifier", null: false
    t.string "park_name", null: false
    t.string "tennis_court_name", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.boolean "now", null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
