class CreateActualUnitUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :actual_unit_urls do |t|
      t.references :actual_unit,
                   null: false,
                   foreign_key: true
      t.references :supplier_url, null: false, foreign_key: true

      t.timestamps
    end
  end
end
