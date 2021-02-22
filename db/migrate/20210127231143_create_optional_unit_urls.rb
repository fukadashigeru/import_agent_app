class CreateOptionalUnitUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :optional_unit_urls do |t|
      t.references :supplier_url, null: false, foreign_key: true
      t.references :optional_unit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
