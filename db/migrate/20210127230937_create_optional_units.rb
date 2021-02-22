class CreateOptionalUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :optional_units do |t|
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
