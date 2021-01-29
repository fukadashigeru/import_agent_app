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
          rows.uniq(&:item_no).map do |row|
            next if indexed_suppliers_by_item_no[row.item_no]

            ordering_org.suppliers.new(shop_type: shop_type, item_no: row.item_no)
          end.compact
        end

        def indexed_suppliers_by_item_no
          @indexed_suppliers_by_item_no ||= ordering_org.suppliers.send(shop_type_key).index_by(&:item_no)
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
