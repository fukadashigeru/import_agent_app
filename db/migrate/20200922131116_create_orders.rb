class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :trade_no
      t.string :title
      t.string :postal
      t.string :address
      t.string :name
      t.string :phone
      t.string :color_size
      t.integer :quantity
      t.integer :status

      t.timestamps
    end
  end
end
