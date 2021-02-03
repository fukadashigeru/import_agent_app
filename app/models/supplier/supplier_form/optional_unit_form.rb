class Supplier
  class SupplierForm
    class OptionalUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :order, Types.Instance(Order)
      attribute :first_priority, Types::Bool.optional.default(false)
      attribute :optional_unit_url_id, Types::Integer.optional.default(nil)
      attribute :url, Types::String.optional.default(''.freeze)

      def save_optional_unit!
        return if url.empty?

        optional_unit =
          if optional_unit_url_id
            update_optional_unit!
          else
            create_optional_unit!
          end

        assign_first_priority(optional_unit) if first_priority
      end

      private

      def create_optional_unit!
        supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)

        supplier.optional_units.create.tap do |optional_unit|
          optional_unit.optional_unit_urls.create(supplier_url: supplier_url)
        end
      end

      def update_optional_unit!
        supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)
        optional_unit_url = indexed_optional_unit_urls_by_id[optional_unit_url_id]
        optional_unit_url.update(supplier_url: supplier_url)
        optional_unit_url.optional_unit
      end

      def assign_first_priority(optional_unit)
        supplier.update(first_priority_unit_id: optional_unit.id)
      end

      def optional_units
        @optional_units ||= supplier.optional_units
      end

      def optional_unit_urls
        @optional_unit_urls ||= optional_units.map(&:optional_unit_urls).flatten
      end

      def indexed_optional_units_by_id
        @indexed_optional_units_by_id ||= optional_units.index_by(&:id)
      end

      def indexed_optional_unit_urls_by_id
        @indexed_optional_unit_urls_by_id ||= optional_unit_urls.index_by(&:id)
      end
    end
  end
end
