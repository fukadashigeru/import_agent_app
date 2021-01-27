class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.references :org, null: false, foreign_key: true

      t.timestamps
    end
  end
end
