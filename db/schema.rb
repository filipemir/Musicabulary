# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160423211103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", force: true do |t|
    t.string   "name",          null: false
    t.integer  "discogs_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "wordiness"
    t.string   "image_discogs"
    t.string   "image_lastfm"
  end

  add_index "artists", ["name"], name: "index_artists_on_name", unique: true, using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "artist_id",               null: false
    t.string   "timeframe",  default: "", null: false
    t.integer  "rank",       default: 0,  null: false
    t.integer  "playcount"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "favorites", ["user_id", "artist_id", "timeframe"], name: "index_favorites_on_user_id_and_artist_id_and_timeframe", unique: true, using: :btree

  create_table "records", force: true do |t|
    t.integer  "artist_id",               null: false
    t.string   "title",      default: "", null: false
    t.integer  "discogs_id"
    t.integer  "year",                    null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "records", ["artist_id", "title", "year"], name: "index_records_on_artist_id_and_title_and_year", unique: true, using: :btree

  create_table "songs", force: true do |t|
    t.integer  "record_id",               null: false
    t.string   "title",      default: "", null: false
    t.text     "lyrics"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "position",   default: ""
  end

  add_index "songs", ["record_id", "title"], name: "index_songs_on_record_id_and_title", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "username"
    t.string   "image"
    t.integer  "playcount"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
