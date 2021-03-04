module PlaceOrders
  class BuildImporter
    class BuymaImporter
      class SupplierImporter < ApplicationStruct
        include ActiveModel::Validations

        attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
        attribute :ordering_org, Types.Instance(Org)
        attribute :shop_type, Types::Params::Integer
        # attribute :rows, Types::Array.of(Types.Instance(CsvRow))

        def call
          import_suppliers!
        end

        private

        def import_suppliers!
          Supplier.import! suppliers
        end

        def suppliers
          rows.uniq(&:item_number).map do |row|
            next if indexed_suppliers_by_item_number[row.item_number]

            ec_shop.suppliers.new(item_number: row.item_number)
          end.compact
        end

        def ec_shop
          @ec_shop ||= ordering_org.ec_shops.find_or_create_by(ec_shop_type: 3)
        end

        def indexed_suppliers_by_item_number
          @indexed_suppliers_by_item_number ||= ordering_org
                                                .suppliers
                                                .ec_shop_is(ec_shop_type_key)
                                                .index_by(&:item_number)
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
      end
    end
  end
end
