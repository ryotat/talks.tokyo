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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130423061936) do

  create_table "custom_views", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.integer "list_id"
    t.string  "limit"
    t.integer "old_id"
    t.string  "view_parameters"
  end

  create_table "document_versions", :force => true do |t|
    t.integer  "document_id"
    t.integer  "version"
    t.string   "name"
    t.text     "body"
    t.text     "html"
    t.integer  "user_id"
    t.string   "administrator_only"
    t.datetime "updated_at"
  end

  add_index "document_versions", ["document_id"], :name => "index_document_versions_on_document_id"
  add_index "document_versions", ["updated_at"], :name => "index_document_versions_on_updated_at"

  create_table "documents", :force => true do |t|
    t.string  "name"
    t.text    "body"
    t.text    "html"
    t.integer "version"
    t.integer "user_id"
    t.boolean "administrator_only"
  end

  add_index "documents", ["name"], :name => "index_documents_on_name"

  create_table "email_subscriptions", :force => true do |t|
    t.integer "user_id"
    t.integer "list_id"
  end

  add_index "email_subscriptions", ["list_id"], :name => "index_email_subscriptions_on_list_id"
  add_index "email_subscriptions", ["user_id"], :name => "index_email_subscriptions_on_user_id"

  create_table "images", :force => true do |t|
    t.binary   "data",       :limit => 16777215
    t.datetime "created_at"
  end

  create_table "list_lists", :force => true do |t|
    t.integer "list_id"
    t.integer "child_id"
    t.string  "dependency"
  end

  add_index "list_lists", ["child_id"], :name => "index_list_lists_on_child_id"
  add_index "list_lists", ["list_id"], :name => "index_list_lists_on_list_id"

  create_table "list_talks", :force => true do |t|
    t.integer "list_id"
    t.integer "talk_id"
    t.string  "dependency"
  end

  add_index "list_talks", ["list_id"], :name => "index_list_talks_on_list_id"
  add_index "list_talks", ["talk_id"], :name => "index_list_talks_on_talk_id"

  create_table "list_users", :force => true do |t|
    t.integer "list_id"
    t.integer "user_id"
  end

  add_index "list_users", ["list_id"], :name => "index_lists_users_on_list_id"
  add_index "list_users", ["user_id"], :name => "index_lists_users_on_user_id"

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.text     "details"
    t.string   "type",               :limit => 50
    t.text     "details_filtered"
    t.boolean  "ex_directory",                     :default => false
    t.integer  "old_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "talk_post_password"
    t.string   "style"
  end

  add_index "lists", ["ex_directory"], :name => "index_lists_on_ex_directory"
  add_index "lists", ["name"], :name => "index_lists_on_name"

  create_table "posted_talks", :force => true do |t|
    t.string   "title"
    t.text     "abstract"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "name_of_speaker"
    t.string   "speaker_email"
    t.string   "sender_ip"
    t.integer  "speaker_id"
    t.integer  "series_id"
    t.integer  "venue_id"
    t.text     "abstract_filtered"
    t.string   "language"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "related_lists", :force => true do |t|
    t.integer "related_id"
    t.string  "related_type"
    t.integer "list_id"
    t.float   "score"
  end

  add_index "related_lists", ["list_id"], :name => "index_related_lists_on_list_id"
  add_index "related_lists", ["related_id", "related_type"], :name => "index_related_lists_on_related_id_and_related_type"
  add_index "related_lists", ["score"], :name => "index_related_lists_on_score"

  create_table "related_talks", :force => true do |t|
    t.integer "related_id"
    t.string  "related_type"
    t.integer "talk_id"
    t.float   "score"
  end

  add_index "related_talks", ["related_id", "related_type"], :name => "index_related_talks_on_related_id_and_related_type"
  add_index "related_talks", ["score"], :name => "index_related_talks_on_score"
  add_index "related_talks", ["talk_id"], :name => "index_related_talks_on_talk_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "talks", :force => true do |t|
    t.string   "title",             :default => ""
    t.text     "abstract"
    t.string   "special_message"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "name_of_speaker"
    t.integer  "speaker_id"
    t.integer  "series_id"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "abstract_filtered"
    t.integer  "organiser_id"
    t.integer  "old_id"
    t.boolean  "ex_directory",      :default => false
    t.integer  "image_id"
    t.string   "language"
  end

  add_index "talks", ["end_time"], :name => "index_talks_on_end_time"
  add_index "talks", ["organiser_id"], :name => "index_talks_on_organiser_id"
  add_index "talks", ["series_id"], :name => "index_talks_on_series_id"
  add_index "talks", ["speaker_id"], :name => "index_talks_on_speaker_id"
  add_index "talks", ["start_time"], :name => "index_talks_on_start_time"

  create_table "tickles", :force => true do |t|
    t.datetime "created_at"
    t.integer  "about_id"
    t.string   "about_type"
    t.integer  "sender_id"
    t.text     "recipient_email"
    t.string   "sender_email"
    t.string   "sender_name"
    t.string   "sender_ip"
  end

  create_table "user_viewed_talks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "talk_id"
    t.datetime "last_seen"
  end

  add_index "user_viewed_talks", ["last_seen"], :name => "index_user_viewed_talks_on_last_seen"
  add_index "user_viewed_talks", ["talk_id"], :name => "index_user_viewed_talks_on_talk_id"
  add_index "user_viewed_talks", ["user_id", "talk_id"], :name => "index_user_viewed_talks_on_user_id_and_talk_id", :unique => true
  add_index "user_viewed_talks", ["user_id"], :name => "index_user_viewed_talks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "affiliation",        :limit => 75
    t.integer  "administrator",                    :default => 0,    :null => false
    t.integer  "old_id"
    t.datetime "last_login"
    t.string   "crsid"
    t.integer  "image_id"
    t.string   "name_in_sort_order"
    t.boolean  "ex_directory",                     :default => true
    t.time     "created_at"
    t.time     "updated_at"
    t.string   "password_digest"
    t.boolean  "suspended"
  end

  add_index "users", ["crsid"], :name => "index_users_on_crsid"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["name_in_sort_order"], :name => "index_users_on_name_in_sort_order"

end
