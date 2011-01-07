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

ActiveRecord::Schema.define(:version => 20110106172902) do

  create_table "addresses", :force => true do |t|
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_rates", :force => true do |t|
    t.integer  "billable_id"
    t.decimal  "dollars",       :precision => 10, :scale => 2
    t.string   "units"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "billable_type"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "web_address"
    t.integer  "address_id"
    t.string   "billing_frequency"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_user_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.integer  "commenter_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type"
  end

  create_table "goals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "workable_id"
    t.string   "workable_type"
    t.string   "period"
    t.decimal  "amount",            :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "units"
    t.integer  "weekday"
    t.date     "daily_date"
    t.float    "daily_goal_amount"
    t.integer  "priority"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "client_id"
    t.integer  "created_by_user_id"
    t.date     "invoice_date"
    t.datetime "paid_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.integer  "client_id"
    t.integer  "created_by_user_id"
    t.string   "name"
    t.datetime "closed_at"
    t.integer  "closed_by_user_id"
    t.integer  "authorized_by_user_id"
    t.datetime "authorized_at"
    t.boolean  "urgent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticket_times", :force => true do |t|
    t.integer  "worker_id"
    t.integer  "ticket_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ticket_times", ["started_at"], :name => "index_ticket_times_on_started_at"

  create_table "tickets", :force => true do |t|
    t.integer  "project_id"
    t.integer  "created_by_user_id"
    t.string   "name"
    t.datetime "closed_at"
    t.integer  "estimated_minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_activity_alerts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "alertable_id"
    t.text     "content"
    t.datetime "dismissed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alertable_type"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "manageable_id"
    t.boolean  "worker"
    t.boolean  "authorizer"
    t.boolean  "admin"
    t.boolean  "finances"
    t.boolean  "invoicer"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manageable_type"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "address_id"
    t.string   "time_zone"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "workweeks", :force => true do |t|
    t.integer  "worker_id"
    t.boolean  "sunday"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
