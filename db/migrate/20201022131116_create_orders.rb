class CreateOrders < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/AbcSize
  def change
    create_table :orders do |t|
      t.string :trade_number, comment: '取引ID'
      t.string :title
      t.string :postal
      t.string :address
      t.string :addressee
      t.string :phone
      t.string :color_size
      t.integer :quantity
      t.integer :selling_unit_price
      t.string :information, comment: '連絡事項'
      t.string :memo, comment: '受注メモ'
      t.integer :status
      t.references :ec_shop, null: false, foreign_key: true
      t.references :buying_org, foreign_key: { to_table: :orgs }

      t.timestamps

      t.index %i[ec_shop_id trade_number], unique: true
    end
  end
  # rubocop:enable Metrics/AbcSize
end
