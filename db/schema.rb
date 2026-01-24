# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_01_24_204635) do
  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_bookmarks_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_bookmarks_on_user_id_and_entry_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "entries", force: :cascade do |t|
    t.integer "feed_id", null: false
    t.string "uuid", null: false
    t.string "link", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "published_at", precision: nil, null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "\"searchable\"", name: "index_entries_on_searchable"
    t.index ["feed_id", "title"], name: "index_entries_on_feed_id_and_title", unique: true
    t.index ["feed_id", "uuid"], name: "index_entries_on_feed_id_and_uuid"
    t.index ["feed_id"], name: "index_entries_on_feed_id"
    t.index ["published_at"], name: "index_entries_on_published_at"
    t.index ["uuid"], name: "index_entries_on_uuid"
  end

# Could not dump table "entry_titles" because of following StandardError
#   Unknown type '' for column 'entry_id'


# Could not dump table "entry_titles_config" because of following StandardError
#   Unknown type '' for column 'k'


# Could not dump table "entry_titles_content" because of following StandardError
#   Unknown type '' for column 'c0'


  create_table "entry_titles_data", force: :cascade do |t|
    t.binary "block"
  end

  create_table "entry_titles_docsize", force: :cascade do |t|
    t.binary "sz"
  end

# Could not dump table "entry_titles_idx" because of following StandardError
#   Unknown type '' for column 'segid'


  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "title", null: false
    t.boolean "active", default: true, null: false
    t.datetime "refresh_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error"
    t.text "description"
    t.string "image_url"
    t.index ["active"], name: "index_feeds_on_active"
    t.index ["refresh_at"], name: "index_feeds_on_refresh_at"
    t.index ["url"], name: "index_feeds_on_url", unique: true
  end

  create_table "filters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "comparison", default: "eq", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_filters_on_user_id"
    t.index ["value", "user_id"], name: "uniq_filter_val_usr_type"
  end

# Could not dump table "old_taggings" because of following StandardError
#   Unknown type '' for column 'id'


# Could not dump table "old_tags" because of following StandardError
#   Unknown type 'serial' for column 'id'


  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "feed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_subscriptions_on_active"
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["user_id", "feed_id", "active"], name: "sub_u_f_a_hfmp"
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "taggable_id"
    t.string "taggable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "viewed_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_viewed_entries_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_viewed_entries_on_user_id_and_entry_id"
    t.index ["user_id"], name: "index_viewed_entries_on_user_id"
  end

  add_foreign_key "bookmarks", "entries"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "entries", "feeds"
  add_foreign_key "filters", "users"
  add_foreign_key "old_taggings", "old_tags", column: "tag_id"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "viewed_entries", "entries"
  add_foreign_key "viewed_entries", "users"
end
