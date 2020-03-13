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

ActiveRecord::Schema.define(version: 2020_03_13_061312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_customers_on_code", unique: true
  end

  create_table "invoice_headers", force: :cascade do |t|
    t.string "number"
    t.string "rep_code"
    t.string "customer_code"
    t.decimal "amount", precision: 10, scale: 2
    t.decimal "cost", precision: 10, scale: 2
    t.date "order_date"
    t.integer "qty_ord"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_code"], name: "index_invoice_headers_on_customer_code"
    t.index ["number"], name: "index_invoice_headers_on_number", unique: true
    t.index ["rep_code"], name: "index_invoice_headers_on_rep_code"
  end

  create_table "invoice_summaries", force: :cascade do |t|
    t.string "batch"
    t.string "number"
    t.string "sales_rep_code"
    t.date "invoiced_on"
    t.date "paid_on"
    t.decimal "amount", precision: 8, scale: 2
    t.decimal "cost", precision: 8, scale: 2
    t.string "customer_code"
    t.string "customer_name"
    t.integer "cases"
    t.boolean "delivered"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["batch", "sales_rep_code"], name: "index_invoice_summaries_on_batch_and_sales_rep_code"
    t.index ["batch"], name: "index_invoice_summaries_on_batch"
    t.index ["number"], name: "index_invoice_summaries_on_number"
    t.index ["sales_rep_code"], name: "index_invoice_summaries_on_sales_rep_code"
  end

  create_table "purged_records", force: :cascade do |t|
    t.string "number"
    t.decimal "amount", precision: 10, scale: 2
    t.string "customer_code"
    t.string "rep_code"
    t.date "due_date"
    t.date "created_date"
    t.string "adj_code"
    t.string "ref_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["adj_code"], name: "index_purged_records_on_adj_code"
    t.index ["number"], name: "index_purged_records_on_number"
    t.index ["rep_code"], name: "index_purged_records_on_rep_code"
  end

  create_table "sales_reps", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "quota_type"
    t.decimal "period1", precision: 8, scale: 2
    t.decimal "period2", precision: 8, scale: 2
    t.decimal "period3", precision: 8, scale: 2
    t.decimal "period4", precision: 8, scale: 2
    t.decimal "period5", precision: 8, scale: 2
    t.decimal "goal1", precision: 8, scale: 2
    t.decimal "goal2", precision: 8, scale: 2
    t.decimal "goal3", precision: 8, scale: 2
    t.decimal "goal4", precision: 8, scale: 2
    t.decimal "goal5", precision: 8, scale: 2
    t.decimal "goal6", precision: 8, scale: 2
    t.decimal "goal7", precision: 8, scale: 2
    t.decimal "goal8", precision: 8, scale: 2
    t.decimal "goal9", precision: 8, scale: 2
    t.decimal "goal10", precision: 8, scale: 2
    t.decimal "comm1", precision: 8, scale: 2
    t.decimal "comm2", precision: 8, scale: 2
    t.decimal "comm3", precision: 8, scale: 2
    t.decimal "comm4", precision: 8, scale: 2
    t.decimal "comm5", precision: 8, scale: 2
    t.decimal "comm6", precision: 8, scale: 2
    t.decimal "comm7", precision: 8, scale: 2
    t.decimal "comm8", precision: 8, scale: 2
    t.decimal "comm9", precision: 8, scale: 2
    t.decimal "comm10", precision: 8, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "disabled", default: false, null: false
    t.index ["code"], name: "index_sales_reps_on_code", unique: true
    t.index ["disabled"], name: "index_sales_reps_on_disabled"
  end

end
