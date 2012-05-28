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

ActiveRecord::Schema.define(:version => 20120528172713) do

  create_table "candidates", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "election_id", :null => false
  end

  add_index "candidates", ["election_id", "name"], :name => "index_candidates_on_election_id_and_name", :unique => true

  create_table "elections", :force => true do |t|
    t.datetime "finish_time",                                 :null => false
    t.text     "info"
    t.string   "name",                                        :null => false
    t.datetime "start_time",                                  :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "user_id",                                     :null => false
    t.boolean  "private",                  :default => true,  :null => false
    t.boolean  "display_votes_as_created", :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",           :null => false
    t.string   "name",            :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest", :null => false
    t.string   "remember_token"
    t.string   "handle",          :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["handle"], :name => "index_users_on_handle", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "votes", :force => true do |t|
    t.string   "vote_string"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
    t.integer  "election_id"
  end

  add_index "votes", ["election_id", "user_id"], :name => "index_votes_on_election_id_and_user_id", :unique => true

end
