class Supplier
  class SupplierForm
    class OptionalUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :first_priority, Types::Bool.optional.default(false)
      attribute :optional_unit_url_id, Types::Integer.optional.default(nil)
      attribute :url, Types::String.optional.default(nil)

      def call!
        return if url.empty?

        create_update_optional_unit!
        assign_first_priority(@optional_unit) if first_priority
      end

      private

      def create_update_optional_unit!
        supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)

        if optional_unit_url_id
          optional_unit_url = OptionalUnitUrl.find(optional_unit_url_id)
          optional_unit_url.update(supplier_url: supplier_url)
          @optional_unit = optional_unit_url.optional_unit
        else
          @optional_unit = supplier.optional_units.create.tap do |optional_unit|
            optional_unit.optional_unit_urls.create(supplier_url: supplier_url)
          end
        end
      end

      def assign_first_priority(optional_unit)
        supplier.update(first_priority_unit_id: optional_unit.id)
      end
    end
  end
end
