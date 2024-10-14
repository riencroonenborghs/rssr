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

ActiveRecord::Schema.define(version: 2024_10_14_192234) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_bookmarks_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_bookmarks_on_user_id_and_entry_id"
    t.index ["user_id", "entry_id"], name: "readltr_usr_entry_rd"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "entries", force: :cascade do |t|
    t.integer "feed_id", null: false
    t.string "guid", null: false
    t.string "link", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "published_at", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "media_title"
    t.string "media_url"
    t.string "media_type"
    t.integer "media_width"
    t.integer "media_height"
    t.string "media_thumbnail_url"
    t.integer "media_thumbnail_height"
    t.integer "media_thumbnail_width"
    t.integer "enclosure_length"
    t.string "enclosure_type"
    t.string "enclosure_url"
    t.string "itunes_duration"
    t.string "itunes_episode_type"
    t.string "itunes_author"
    t.boolean "itunes_explicit"
    t.string "itunes_image"
    t.string "itunes_title"
    t.string "itunes_summary"
    t.datetime "viewed_at"
    t.datetime "downloaded_at"
    t.index ["downloaded_at"], name: "index_entries_on_downloaded_at"
    t.index ["feed_id", "guid"], name: "index_entries_on_feed_id_and_guid"
    t.index ["feed_id"], name: "index_entries_on_feed_id"
    t.index ["guid"], name: "index_entries_on_guid"
    t.index ["published_at"], name: "index_entries_on_published_at"
    t.index ["viewed_at", "downloaded_at"], name: "index_entries_on_viewed_at_and_downloaded_at"
    t.index ["viewed_at"], name: "index_entries_on_viewed_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "refresh_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "error"
    t.text "description"
    t.string "image_url"
    t.string "rss_url", null: false
    t.index ["active"], name: "index_feeds_on_active"
    t.index ["refresh_at"], name: "index_feeds_on_refresh_at"
    t.index ["url"], name: "index_feeds_on_url"
  end

  create_table "filters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "comparison", default: "eq", null: false
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_filters_on_user_id"
    t.index ["value", "user_id"], name: "filter_val_usr_type"
    t.index ["value", "user_id"], name: "uniq_filter_val_usr_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "entry_id", null: false
    t.integer "watch_group_id", null: false
    t.datetime "acked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_notifications_on_entry_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "feed_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true, null: false
    t.boolean "hide_from_main_page", default: false
    t.index ["active"], name: "index_subscriptions_on_active"
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["hide_from_main_page"], name: "index_subscriptions_on_hide_from_main_page"
    t.index ["user_id", "feed_id", "active", "hide_from_main_page"], name: "sub_u_f_a_hfmp"
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
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

  create_table "tags", force: :cascade do |t|
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
    t.integer "user_id", null: false
    t.integer "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_viewed_entries_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_viewed_entries_on_user_id_and_entry_id"
    t.index ["user_id"], name: "index_viewed_entries_on_user_id"
  end

  create_table "watches", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "watch_type", null: false
    t.string "value", null: false
    t.integer "group_id", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_watches_on_user_id"
    t.index ["value", "watch_type", "user_id"], name: "uniq_watch_combniation"
  end

  add_foreign_key "bookmarks", "entries"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "entries", "feeds"
  add_foreign_key "filters", "users"
  add_foreign_key "notifications", "entries"
  add_foreign_key "notifications", "users"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "viewed_entries", "entries"
  add_foreign_key "viewed_entries", "users"
  add_foreign_key "watches", "users"
end
