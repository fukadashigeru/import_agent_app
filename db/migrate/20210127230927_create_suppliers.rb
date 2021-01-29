class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.references :org, null: false, foreign_key: true
      t.integer :shop_type
      t.string :item_no, comment: '商品ID'

      t.timestamps
    end
  end
end
