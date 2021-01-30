module PlaceOrders
  class BuildImporter
    class BuymaImporter
      class OrderImporter < ApplicationStruct
        include ActiveModel::Validations

        attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
        attribute :ordering_org, Types.Instance(Org)
        attribute :shop_type, Types::Params::Integer
        # attribute :rows, Types::Array.of(Types.Instance(CsvRow))

        def call
          import_orders!
        end

        private

        def import_orders!
          Order.import! orders
        end

        def orders
          rows.map do |row|
            build_order(row) if !indexed_orders_by_trade_no[row.trade_no]
          end.compact
        end

        # rubocop:disable Metrics/AbcSize
        def build_order(row)
          ordering_org.orders_to_order.new(
            shop_type: shop_type,
            item_no: row.item_no,
            trade_no: row.trade_no,
            title: row.title,
            postal: row.postal,
            address: row.address,
            addressee: row.addressee,
            phone: row.phone,
            color_size: row.color_size,
            quantity: row.quantity,
            selling_unit_price: row.selling_unit_price,
            information: row.information,
            memo: row.memo,
            status: :before_order,
            supplier: indexed_suppliers_by_item_no[row.item_no]
          )
        end
        # rubocop:enable Metrics/AbcSize

        def indexed_suppliers_by_item_no
          @indexed_suppliers_by_item_no ||= ordering_org.suppliers.send(shop_type_key).index_by(&:item_no)
        end

        def indexed_orders_by_trade_no
          @indexed_orders_by_trade_no ||= ordering_org
                                          .orders_to_order
                                          .send(shop_type_key)
                                          .index_by(&:trade_no)
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
      end
    end
  end
end
