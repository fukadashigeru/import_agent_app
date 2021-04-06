class CreateEcShops < ActiveRecord::Migration[6.0]
  def change
    create_table :ec_shops do |t|
      t.integer :ec_shop_type
      t.references :org, null: false, foreign_key: true

      t.timestamps
    end
  end
end
