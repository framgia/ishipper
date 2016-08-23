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

ActiveRecord::Schema.define(version: 20160803021915) do

  create_table "invoice_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "attribute_name"
    t.string   "before_value"
    t.string   "after_value"
    t.integer  "user_id"
    t.integer  "invoice_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["invoice_id"], name: "index_invoice_histories_on_invoice_id", using: :btree
  end

  create_table "invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "address_start"
    t.float    "latitude_start",   limit: 24
    t.float    "longitude_start",  limit: 24
    t.string   "address_finish"
    t.float    "latitude_finish",  limit: 24
    t.float    "longitude_finish", limit: 24
    t.string   "delivery_time"
    t.float    "distance",         limit: 24
    t.string   "description"
    t.float    "price",            limit: 24
    t.float    "shipping_price",   limit: 24
    t.integer  "status"
    t.float    "weight",           limit: 24
    t.string   "customer_name"
    t.string   "customer_number"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["user_id"], name: "index_invoices_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "owner_id"
    t.integer  "recipient_id"
    t.string   "key"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "owner_id"
    t.integer  "recipient_id"
    t.integer  "invoice_id"
    t.integer  "review_type"
    t.float    "rating_point", limit: 24
    t.string   "content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["invoice_id"], name: "index_reviews_on_invoice_id", using: :btree
  end

  create_table "user_invoice_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "attribute_name"
    t.string   "before_value"
    t.string   "after_value"
    t.integer  "user_invoice_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["user_invoice_id"], name: "index_user_invoice_histories_on_user_invoice_id", using: :btree
  end

  create_table "user_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "status",     default: 0
    t.integer  "user_id"
    t.integer  "invoice_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["invoice_id"], name: "index_user_invoices_on_invoice_id", using: :btree
    t.index ["user_id"], name: "index_user_invoices_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "current_location"
    t.float    "latitude",               limit: 24
    t.float    "longitude",              limit: 24
    t.string   "phone_number"
    t.string   "plate_number"
    t.integer  "status",                            default: 0
    t.integer  "role"
    t.float    "rate",                   limit: 24
    t.string   "pin"
    t.string   "authentication_token"
    t.boolean  "signed_in"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "invoice_histories", "invoices"
  add_foreign_key "invoices", "users"
  add_foreign_key "reviews", "invoices"
  add_foreign_key "user_invoice_histories", "user_invoices"
  add_foreign_key "user_invoices", "invoices"
  add_foreign_key "user_invoices", "users"
end
