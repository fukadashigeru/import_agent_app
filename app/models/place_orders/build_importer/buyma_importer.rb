module PlaceOrders
  class BuildImporter
    class BuymaImporter < ApplicationStruct
      include ActiveModel::Validations

      attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
      attribute :ordering_org, Types.Instance(Org)
      attribute :shop_type, Types::Params::Integer

      validate :orders_empty

      BATCH_SIZE = 300

      def call
        return false if invalid?

        ApplicationRecord.transaction do
          import_supplier!
        end
      end

      # private

      def import_supplier!
        SupplierImporter.new(
          io: io,
          ordering_org: ordering_org,
          shop_type: shop_type,
          # rows: rows
        ).call
      end

      def shop_type_key
        @shop_type_key ||= ShopType.find_by_id(shop_type).key
      end

      # def import_orders!
      #   Order.import! orders,
      #                 recursive: true
      # end

      def rows
        @rows ||= read_csv.map do |row|
          CsvRow.new(row: row)
        end
      end

      def read_csv
        @read_csv ||= CSV.parse(csv_string, headers: true, liberal_parsing: true)
      end

      def csv_string
        @csv_string ||= NKF.nkf('-xw', io.read)
      end

      # def item_no_map
      #   @item_no_map ||= read_csv.map { |row| row[HeaderColumns::ITEM_NO] }.uniq
      # end

      # def orders
      #   @orders ||= rows.group_by(&:item_no).each_with_object([]) do |rows_group_by_item_no, array|
      #     item_no = rows_group_by_item_no.first
      #     supplier = find_or_create_supplier(item_no)
      #     rows_group_by_item_no.second.each do |row|
      #       array << build_order(row, supplier)
      #     end
      #   end.compact
      # end

      # def find_or_create_supplier(item_no)
      #   indexed_suppliers_by_item_no[item_no] || ordering_org.suppliers.create(shop_type: shop_type, item_no: item_no)
      # end

      # def indexed_suppliers_by_item_no
      #   @indexed_suppliers_by_item_no ||= ordering_org.suppliers.where(shop_type: shop_type).index_by(&:item_no)
      # end

      # # rubocop:disable Metrics/AbcSize
      # def build_order(row, supplier)
      #   if check_imported_yet(row)
      #     Order.new(
      #       shop_type: shop_type,
      #       item_no: row.item_no,
      #       trade_no: row.trade_no,
      #       title: row.title,
      #       postal: row.postal,
      #       address: row.address,
      #       addressee: row.addressee,
      #       phone: row.phone,
      #       color_size: row.color_size,
      #       quantity: row.quantity,
      #       selling_unit_price: row.selling_unit_price,
      #       information: row.information,
      #       memo: row.memo,
      #       status: :before_order,
      #       ordering_org: ordering_org,
      #       supplier: supplier
      #     )
      #   end
      # end
      # # rubocop:enable Metrics/AbcSize

      # def check_imported_yet(row)
      #   !indexed_orders_by_trade_no.key?(row.trade_no)
      # end

      # def indexed_orders_by_trade_no
      #   @indexed_orders_by_trade_no ||= ordering_org.orders_to_order.where(shop_type: :buyma).index_by(&:trade_no)
      # end

      # def orders_empty
      #   errors.add(:base, '新しくインポートできる注文はありません。') if orders.empty?
      # end
    end
  end
end
