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

ActiveRecord::Schema.define(version: 20131025053714) do

  create_table "blog_posts", force: true do |t|
    t.integer  "remote_id"
    t.string   "url"
    t.string   "title"
    t.text     "content"
    t.datetime "published"
    t.datetime "last_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "plaintext"
    t.string   "image"
    t.string   "caption"
  end

  create_table "broadcasts", force: true do |t|
    t.string   "message"
    t.datetime "show_from"
    t.datetime "show_until"
    t.string   "author_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "broadcasts_buildings", id: false, force: true do |t|
    t.integer "broadcast_id"
    t.integer "building_id"
  end

  create_table "buildings", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "class_groups", force: true do |t|
    t.integer  "class_type_id"
    t.integer  "group_number"
    t.string   "note"
    t.boolean  "full"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "class_groups", ["class_type_id"], name: "index_class_groups_on_class_type_id", using: :btree

  create_table "class_sessions", force: true do |t|
    t.integer  "class_group_id"
    t.date     "first_day"
    t.date     "last_day"
    t.integer  "day_of_week",    limit: 2
    t.integer  "time_starts_at"
    t.integer  "time_ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "room_id"
  end

  add_index "class_sessions", ["class_group_id"], name: "index_class_sessions_on_class_group_id", using: :btree
  add_index "class_sessions", ["room_id"], name: "index_class_sessions_on_room_id", using: :btree

  create_table "class_types", force: true do |t|
    t.integer  "topic_id"
    t.string   "name"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "class_types", ["topic_id"], name: "index_class_types_on_topic_id", using: :btree

  create_table "room_bookings", force: true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description"
    t.boolean  "cancelled"
    t.integer  "room_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "booked_for"
    t.string   "type"
  end

  create_table "rooms", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.integer  "capacity"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "term_dates", force: true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string   "semester"
    t.string   "week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", force: true do |t|
    t.string   "name"
    t.string   "subject_area",        limit: 4
    t.string   "topic_number",        limit: 5
    t.integer  "year"
    t.string   "semester",            limit: 3
    t.decimal  "units",                         precision: 4, scale: 1
    t.string   "coordinator"
    t.text     "description"
    t.text     "aims"
    t.text     "learning_outcomes"
    t.text     "assumed_knowledge"
    t.text     "assessment"
    t.text     "class_contact"
    t.date     "enrolment_opens"
    t.date     "census"
    t.date     "withdraw_no_fail_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "enrolment_closes"
    t.string   "code"
    t.string   "unique_topic_code"
  end

  add_index "topics", ["unique_topic_code"], name: "index_topics_on_unique_topic_code", using: :btree

end
