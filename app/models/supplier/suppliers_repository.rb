class Supplier
  class SuppliersRepository < ApplicationStruct
    attribute :org, Types::Instance(Org)

    def suppliers
      @suppliers ||=
        org
        .suppliers
        .includes(
          first_priority_unit: :supplier_urls,
          optional_units: :supplier_urls,
          orders: { actual_unit: :supplier_urls }
        )
    end

    def indexed_all_supplier_urls_is_same_by_supplier
      @indexed_all_supplier_urls_is_same_by_supplier ||=
        suppliers.index_with(&:all_supplier_urls_is_same?)
    end
  end
end
