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

ActiveRecord::Schema.define(version: 20180324150438) do

  create_table "blacklist_items", force: :cascade do |t|
    t.string "word"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profession_id"
    t.integer "professions_id"
    t.index ["profession_id"], name: "index_blacklist_items_on_profession_id"
    t.index ["professions_id"], name: "index_blacklist_items_on_professions_id"
  end

  create_table "blacklist_items_professions", id: false, force: :cascade do |t|
    t.integer "blacklist_item_id", null: false
    t.integer "profession_id", null: false
    t.index ["blacklist_item_id", "profession_id"], name: "by_blacklist_item_id"
    t.index ["profession_id", "blacklist_item_id"], name: "by_profession_item_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_professions_on_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "uid"
    t.string "password_hash"
    t.string "salt"
    t.integer "type"
    t.boolean "verified"
    t.string "auth"
    t.string "login_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "otp_count"
    t.string "fcm_token"
    t.index ["uid", "verified"], name: "index_users_on_uid_and_verified", unique: true
  end

end
