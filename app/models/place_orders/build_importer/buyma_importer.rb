module PlaceOrders
  class BuildImporter
    class BuymaImporter < ApplicationStruct
      include ActiveModel::Validations

      attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
      attribute :ordering_org, Types.Instance(Org)
      attribute :shop_type, Types::Params::Integer

      validate :new_order_present
      validate :check_trade_no_duplication

      BATCH_SIZE = 300

      def call
        return false if invalid?

        ApplicationRecord.transaction do
          import_suppliers!
          import_orders!
        end
      end

      private

      def import_suppliers!
        SupplierImporter.new(
          io: StringIO.new(csv_string),
          ordering_org: ordering_org,
          shop_type: shop_type
        ).call
      end

      def import_orders!
        OrderImporter.new(
          io: StringIO.new(csv_string),
          ordering_org: ordering_org,
          shop_type: shop_type
        ).call
      end

      def shop_type_key
        @shop_type_key ||= ShopType.find_by_id(shop_type).key
      end

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

      def csv_trade_no_array
        @csv_trade_no_array ||= rows.map(&:trade_no)
      end

      def orders_trade_no_array
        @orders_trade_no_array ||= ordering_org.orders_to_order.send(shop_type_key).map(&:trade_no)
      end

      def new_order
        @new_order ||= csv_trade_no_array - orders_trade_no_array
      end

      def new_order_present
        errors.add(:base, '新しくインポートできる注文はありません。') if new_order.empty?
      end

      def duplication_presence
        (csv_trade_no_array.count - csv_trade_no_array.uniq.count).positive?
      end

      def check_trade_no_duplication
        errors.add(:base, 'ファイル内に同じお取引IDが2件以上ありインポートできません。') if duplication_presence
      end
    end
  end
end
