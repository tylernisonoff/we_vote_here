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

ActiveRecord::Schema.define(:version => 20121025180716) do

  create_table "choices", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "election_id", :null => false
  end

  add_index "choices", ["election_id", "name"], :name => "index_choices_on_election_id_and_name", :unique => true

  create_table "elections", :force => true do |t|
    t.string   "name",                          :null => false
    t.text     "info"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "group_id"
    t.datetime "start_time",                    :null => false
    t.datetime "finish_time",                   :null => false
    t.integer  "user_id"
    t.boolean  "privacy",     :default => true
  end

  add_index "elections", ["group_id"], :name => "index_elections_on_group_id"

  create_table "groups", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id",     :null => false
    t.integer  "election_id"
  end

  add_index "groups", ["election_id"], :name => "index_groups_on_election_id", :unique => true

  create_table "inclusions", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "group_id",    :null => false
    t.integer  "election_id", :null => false
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "voter_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "preferences", :force => true do |t|
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "vote_id",      :limit => 255,                    :null => false
    t.integer  "position",                                       :null => false
    t.integer  "choice_id",                                      :null => false
    t.string   "svc"
    t.boolean  "active",                      :default => true
    t.boolean  "tie_breaking",                :default => false
  end

  add_index "preferences", ["svc"], :name => "index_preferences_on_svc"
  add_index "preferences", ["vote_id", "choice_id"], :name => "index_preferences_on_vote_id_and_choice_id", :unique => true
  add_index "preferences", ["vote_id"], :name => "index_preferences_on_vote_id"

  create_table "results", :force => true do |t|
    t.integer  "election_id"
    t.integer  "choice_id"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "results", ["election_id", "choice_id"], :name => "index_results_on_election_id_and_choice_id", :unique => true

  create_table "user_emails", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "email",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_emails", ["email"], :name => "index_user_emails_on_email", :unique => true
  add_index "user_emails", ["user_id"], :name => "index_user_emails_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "unconfirmed_email"
    t.string   "nickname",               :default => "", :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "valid_emails", :force => true do |t|
    t.string   "email",      :null => false
    t.integer  "voter_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "valid_svcs", :force => true do |t|
    t.string   "svc",                            :null => false
    t.integer  "election_id",                    :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "trashed",     :default => false
  end

  add_index "valid_svcs", ["svc"], :name => "index_valid_svcs_on_svc", :unique => true

  create_table "voters", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "votes", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "election_id",                     :null => false
    t.string   "svc",                             :null => false
    t.boolean  "active",       :default => false
    t.boolean  "tie_breaking", :default => false
  end

  add_index "votes", ["svc"], :name => "index_votes_on_svc"

end
