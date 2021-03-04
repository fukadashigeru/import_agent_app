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
          Order.import! orders,
                        recursive: true
        end

        def orders
          rows.map do |row|
            build_order(row) if !indexed_orders_by_trade_number[row.trade_number]
          end.compact
        end

        # rubocop:disable Metrics/AbcSize
        def build_order(row)
          supplier = indexed_suppliers_by_item_number[row.item_number]

          ordering_org.orders_to_order.new(
            trade_number: row.trade_number,
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
            supplier: supplier,
            ec_shop: supplier.ec_shop,
            actual_unit: build_actual_unit(supplier)
          )
        end
        # rubocop:enable Metrics/AbcSize

        def indexed_suppliers_by_item_number
          @indexed_suppliers_by_item_number ||= ordering_org.suppliers.ec_shop_is(ec_shop_type_key).index_by(&:item_number)
        end

        def indexed_orders_by_trade_number
          @indexed_orders_by_trade_number ||= ordering_org
                                              .orders_to_order
                                              .ec_shop_is(ec_shop_type_key)
                                              .index_by(&:trade_number)
        end

        def ec_shop_type_key
          @ec_shop_type_key ||= EcShopType.find_by_id(shop_type).key
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

        def build_actual_unit(supplier)
          return nil unless supplier.first_priority_unit

          ActualUnit.new(
            supplier_urls: supplier.first_priority_unit.supplier_urls
          )
        end
      end
    end
  end
end
