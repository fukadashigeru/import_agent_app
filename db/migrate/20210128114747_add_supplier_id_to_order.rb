class AddSupplierIdToOrder < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :supplier, foreign_key: true
  end
end
