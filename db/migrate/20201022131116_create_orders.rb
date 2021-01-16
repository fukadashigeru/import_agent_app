class CreateOrders < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/AbcSize
  def change
    create_table :orders do |t|
      t.integer :shop_type
      t.string :trade_no
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
      t.references :ordering_org, foreign_key: { to_table: :orgs }
      t.references :buying_org, foreign_key: { to_table: :orgs }

      t.timestamps
    end
  end
  # rubocop:enable Metrics/AbcSize
end
