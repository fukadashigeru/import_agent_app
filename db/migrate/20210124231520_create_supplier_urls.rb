class CreateSupplierUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :supplier_urls do |t|
      t.string :url
      t.boolean :is_have_stock, null: false, default: true
      t.references :org, null: false, foreign_key: true

      t.timestamps
    end
  end
end
