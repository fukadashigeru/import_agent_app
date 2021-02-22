class AddFirstPriorityUnitColumnToSupplier < ActiveRecord::Migration[6.0]
  def change
    add_reference :suppliers, :first_priority_unit, foreign_key: { to_table: :optional_units }
  end
end
