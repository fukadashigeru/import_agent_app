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

ActiveRecord::Schema.define(version: 2021_01_28_114747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actual_unit_urls", force: :cascade do |t|
    t.bigint "actual_unit_id", null: false
    t.bigint "supplier_url_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["actual_unit_id"], name: "index_actual_unit_urls_on_actual_unit_id"
    t.index ["supplier_url_id"], name: "index_actual_unit_urls_on_supplier_url_id"
  end

  create_table "actual_units", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_actual_units_on_order_id"
  end

  create_table "ec_shops", force: :cascade do |t|
    t.integer "ec_shop_type"
    t.bigint "org_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["org_id"], name: "index_ec_shops_on_org_id"
  end

  create_table "optional_unit_urls", force: :cascade do |t|
    t.bigint "supplier_url_id", null: false
    t.bigint "optional_unit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["optional_unit_id"], name: "index_optional_unit_urls_on_optional_unit_id"
    t.index ["supplier_url_id"], name: "index_optional_unit_urls_on_supplier_url_id"
  end

  create_table "optional_units", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["supplier_id"], name: "index_optional_units_on_supplier_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "trade_number", comment: "取引ID"
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
    t.bigint "ec_shop_id", null: false
    t.bigint "buying_org_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "supplier_id"
    t.index ["buying_org_id"], name: "index_orders_on_buying_org_id"
    t.index ["ec_shop_id", "trade_number"], name: "index_orders_on_ec_shop_id_and_trade_number", unique: true
    t.index ["ec_shop_id"], name: "index_orders_on_ec_shop_id"
    t.index ["supplier_id"], name: "index_orders_on_supplier_id"
  end

  create_table "orgs", force: :cascade do |t|
    t.string "name"
    t.integer "org_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "supplier_urls", force: :cascade do |t|
    t.string "url"
    t.boolean "is_have_stock", default: true, null: false
    t.bigint "org_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["org_id"], name: "index_supplier_urls_on_org_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "ec_shop_id", null: false
    t.boolean "is_have_stock", default: true, null: false
    t.string "item_number", comment: "商品ID"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "first_priority_unit_id"
    t.index ["ec_shop_id", "item_number"], name: "index_suppliers_on_ec_shop_id_and_item_number", unique: true
    t.index ["ec_shop_id"], name: "index_suppliers_on_ec_shop_id"
    t.index ["first_priority_unit_id"], name: "index_suppliers_on_first_priority_unit_id"
  end

  add_foreign_key "actual_unit_urls", "actual_units"
  add_foreign_key "actual_unit_urls", "supplier_urls"
  add_foreign_key "actual_units", "orders"
  add_foreign_key "ec_shops", "orgs"
  add_foreign_key "optional_unit_urls", "optional_units"
  add_foreign_key "optional_unit_urls", "supplier_urls"
  add_foreign_key "optional_units", "suppliers"
  add_foreign_key "orders", "ec_shops"
  add_foreign_key "orders", "orgs", column: "buying_org_id"
  add_foreign_key "orders", "suppliers"
  add_foreign_key "supplier_urls", "orgs"
  add_foreign_key "suppliers", "ec_shops"
  add_foreign_key "suppliers", "optional_units", column: "first_priority_unit_id"
end
