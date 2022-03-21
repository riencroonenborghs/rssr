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

ActiveRecord::Schema.define(version: 2022_03_22_040009) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.string "entry_id", null: false
    t.string "url", null: false
    t.string "title", null: false
    t.string "summary"
    t.datetime "published_at", null: false
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_entries_on_entry_id"
    t.index ["feed_id", "entry_id"], name: "index_entries_on_feed_id_and_entry_id"
    t.index ["feed_id"], name: "index_entries_on_feed_id"
    t.index ["published_at"], name: "index_entries_on_published_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_visited"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "error"
    t.text "description"
    t.string "image_url"
    t.index ["active"], name: "index_feeds_on_active"
    t.index ["last_visited"], name: "index_feeds_on_last_visited"
    t.index ["url"], name: "index_feeds_on_url"
  end

  create_table "filters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "comparison", default: "eq", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_filters_on_user_id"
    t.index ["value", "user_id"], name: "uniq_filter_val_usr_type"
  end

  create_table "read_later_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "read"
    t.index ["entry_id"], name: "index_read_later_entries_on_entry_id"
    t.index ["read"], name: "index_read_later_entries_on_read"
    t.index ["user_id", "entry_id", "read"], name: "readltr_usr_entry_rd"
    t.index ["user_id", "entry_id"], name: "index_read_later_entries_on_user_id_and_entry_id"
    t.index ["user_id"], name: "index_read_later_entries_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "feed_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_subscriptions_on_active"
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["user_id", "feed_id", "active"], name: "sub_usr_fd_actv"
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "name"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "viewed_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_viewed_entries_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_viewed_entries_on_user_id_and_entry_id"
    t.index ["user_id"], name: "index_viewed_entries_on_user_id"
  end

  add_foreign_key "entries", "feeds"
  add_foreign_key "filters", "users"
  add_foreign_key "read_later_entries", "entries"
  add_foreign_key "read_later_entries", "users"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "viewed_entries", "entries"
  add_foreign_key "viewed_entries", "users"
end
