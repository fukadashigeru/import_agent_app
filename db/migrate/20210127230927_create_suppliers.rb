class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.references :ec_shop, null: false, foreign_key: true
      t.boolean :is_have_stock, null: false, default: true
      t.string :item_number, comment: '商品ID'

      t.timestamps

      t.index %i[ec_shop_id item_number], unique: true
    end
  end
end
