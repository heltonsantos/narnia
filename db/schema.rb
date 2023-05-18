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

ActiveRecord::Schema.define(version: 2023_05_15_203215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uuid"], name: "index_clients_on_uuid", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.string "uuid"
    t.string "type"
    t.string "status"
    t.decimal "unit_price"
    t.integer "quantity"
    t.string "stock_kind"
    t.string "error_message"
    t.integer "retry_count", default: 0
    t.date "expired_at"
    t.datetime "processing_at"
    t.datetime "partial_completed_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.datetime "retryed_at"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_orders_on_client_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "uuid"
    t.integer "kind"
    t.string "status"
    t.datetime "available_at"
    t.datetime "on_sale_at"
    t.bigint "wallet_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.index ["order_id"], name: "index_stocks_on_order_id"
    t.index ["uuid"], name: "index_stocks_on_uuid", unique: true
    t.index ["wallet_id"], name: "index_stocks_on_wallet_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "uuid"
    t.string "type"
    t.integer "nature"
    t.decimal "value"
    t.string "description"
    t.bigint "wallet_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uuid"], name: "index_transactions_on_uuid", unique: true
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.decimal "balance"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_wallets_on_client_id"
  end

  add_foreign_key "orders", "clients"
  add_foreign_key "stocks", "orders"
  add_foreign_key "stocks", "wallets"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "wallets", "clients"
end
