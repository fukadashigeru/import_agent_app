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

ActiveRecord::Schema.define(version: 2020_10_22_131116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.integer "shop_type"
    t.string "trade_no"
    t.string "title"
    t.string "postal"
    t.string "address"
    t.string "addressee"
    t.string "phone"
    t.string "color_size"
    t.integer "quantity"
    t.integer "selling_unit_price"
    t.string "information", comment: "連絡事項"
    t.string "memo", comment: "受注メモ"
    t.integer "status"
    t.bigint "ordering_org_id"
    t.bigint "buying_org_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buying_org_id"], name: "index_orders_on_buying_org_id"
    t.index ["ordering_org_id"], name: "index_orders_on_ordering_org_id"
  end

  create_table "orgs", force: :cascade do |t|
    t.string "name"
    t.integer "org_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "orders", "orgs", column: "buying_org_id"
  add_foreign_key "orders", "orgs", column: "ordering_org_id"
end
