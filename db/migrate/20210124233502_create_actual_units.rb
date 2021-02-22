class CreateActualUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :actual_units do |t|
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
