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

ActiveRecord::Schema.define(:version => 20120712170740) do

  create_table "candidates", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "question_id", :null => false
  end

  add_index "candidates", ["question_id", "name"], :name => "index_candidates_on_question_id_and_name", :unique => true

  create_table "elections", :force => true do |t|
    t.datetime "finish_time",                                 :null => false
    t.text     "info"
    t.string   "name",                                        :null => false
    t.datetime "start_time",                                  :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "user_id",                                     :null => false
    t.boolean  "display_votes_as_created", :default => false, :null => false
    t.boolean  "privacy",                  :default => true,  :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "candidate_id", :null => false
    t.integer  "position",     :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "vote_id"
  end

  add_index "preferences", ["vote_id", "candidate_id"], :name => "index_preferences_on_vote_id_and_candidate_id", :unique => true
  add_index "preferences", ["vote_id", "position"], :name => "index_preferences_on_vote_id_and_position", :unique => true

  create_table "questions", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "info"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "election_id", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",           :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest", :null => false
    t.string   "remember_token"
    t.string   "handle",          :null => false
    t.string   "nickname"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["handle"], :name => "index_users_on_handle", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "valid_emails", :force => true do |t|
    t.string   "email",       :null => false
    t.integer  "voter_id",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "election_id", :null => false
  end

  add_index "valid_emails", ["election_id", "email"], :name => "index_valid_emails_on_election_id_and_email", :unique => true

  create_table "valid_svcs", :force => true do |t|
    t.string   "svc",         :null => false
    t.integer  "question_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "valid_svcs", ["svc"], :name => "index_valid_svcs_on_svc", :unique => true

  create_table "voters", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "election_id", :null => false
  end

  create_table "votes", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "question_id", :null => false
    t.string   "svc",         :null => false
    t.string   "bsn",         :null => false
  end

  add_index "votes", ["svc"], :name => "index_votes_on_svc", :unique => true

end
