module PlaceOrders
  class BuildImporter
    class BuymaImporter < ApplicationStruct
      include ActiveModel::Validations

      attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
      attribute :ordering_org, Types.Instance(Org)
      attribute :shop_type, Types::Params::Integer

      validate :orders_empty

      BATCH_SIZE = 300

      module HeaderColumns
        ITEM_NO = '商品ID'.freeze
        TRADE_NO = '取引ID'.freeze
        TITLE = '商品名'.freeze
        POSTAL = '郵便番号'.freeze
        ADDRESS = '住所'.freeze
        NAME = '名前（本名）'.freeze
        PHONE = '電話番号'.freeze
        COLOR_SIZE = '色・サイズ'.freeze
        QUANTITY = '受注数'.freeze
        SELLING_UNIT_PRICE = '価格'.freeze
        INFORMATION = '連絡事項'.freeze
        MEMO = '受注メモ'.freeze
      end

      def call
        return false if invalid?

        ApplicationRecord.transaction do
          import_suppliers!
          import_orders!
        end
      end

      private

      def shop_type_key
        @shop_type_key ||= ShopType.find_by_id(shop_type).key
      end

      def import_suppliers!
        Supplier.import! suppliers
      end

      def import_orders!
        Order.import! orders
      end

      def csv_string
        @csv_string ||= NKF.nkf('-xw', io.read)
      end

      def read_csv
        @read_csv ||= CSV.parse(csv_string, headers: true, liberal_parsing: true)
      end

      def item_no_map
        @item_no_map ||= read_csv.map { |row| row[HeaderColumns::ITEM_NO] }.uniq
      end

      def suppliers
        @suppliers ||=
          item_no_map.map do |item_no|
            build_supplier(item_no)
          end.compact
      end

      def build_supplier(item_no)
        return if suppliers_map_before_import.key?(item_no)

        ordering_org.suppliers.build(
          shop_type: shop_type,
          item_no: item_no
        )
      end

      def suppliers_map_before_import
        @suppliers_map_before_import ||= ordering_org
                                         .suppliers
                                         .where(shop_type: shop_type)
                                         .index_by(&:item_no)
      end

      def orders_importing_from_now
        @orders_importing_from_now ||= 
          read_csv.map do |row|
            if check_imported_yet(row)
              row[HeaderColumns::ITEM_NO]
            end
          end.compact.reverse
      end

      def orders
        @orders ||=
          read_csv.map do |row|
            build_order(row)
          end.compact.reverse
      end

      # rubocop:disable Metrics/AbcSize
      def build_order(row)
        if check_imported_yet(row)
          Order.new(
            shop_type: shop_type,
            item_no: row[HeaderColumns::ITEM_NO],
            trade_no: row[HeaderColumns::TRADE_NO],
            title: row[HeaderColumns::TITLE],
            postal: row[HeaderColumns::POSTAL],
            address: row[HeaderColumns::ADDRESS],
            addressee: row[HeaderColumns::NAME],
            phone: row[HeaderColumns::PHONE],
            color_size: row[HeaderColumns::COLOR_SIZE],
            quantity: row[HeaderColumns::QUANTITY].to_i,
            selling_unit_price: row[HeaderColumns::SELLING_UNIT_PRICE].to_i,
            information: row[HeaderColumns::INFORMATION],
            memo: row[HeaderColumns::MEMO],
            status: :before_order,
            ordering_org: ordering_org,
            supplier: supplires_map_after_import[row[HeaderColumns::ITEM_NO]]
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def check_imported_yet(row)
        !buyma_trade_no_hash.key?(row[HeaderColumns::TRADE_NO])
      end

      def buyma_trade_no_hash
        @buyma_trade_no_hash ||= ordering_org.orders_to_order.where(shop_type: :buyma).index_by(&:trade_no)
      end

      def supplires_map_after_import
        @supplires_map_after_import ||= ordering_org.suppliers.where(shop_type: shop_type).index_by(&:item_no)
      end

      def orders_empty
        errors.add(:base, '新しくインポートできる注文はありません。') if orders_importing_from_now.empty?
      end
    end
  end
end
