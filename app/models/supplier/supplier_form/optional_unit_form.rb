class Supplier
  class SupplierForm
    class OptionalUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :optional_unit, Types.Instance(OptionalUnit).optional.default(nil)
      # attribute :order, Types.Instance(Order)
      attribute :first_priority, Types::Bool.optional.default(false)
      attribute :optional_unit_url_id_and_url_array, (
        Types::Array.of(
          Types::Hash.schema(
            optional_unit_url_id: (Types::Optional::Integer | Types::Optional::String).optional.default(nil),
            url: Types::String.default(''.freeze)
          )
        ).optional.default { [] }
      )

      def save_optional_unit!
        if optional_unit
          update_optional_unit!(optional_unit_url_id_and_url_array)
        else
          create_optional_unit!(optional_unit_url_id_and_url_array)
        end

        assign_first_priority(optional_unit) if first_priority
      end

      private

      def create_optional_unit!(optional_unit_url_id_and_url_array)
        supplier.optional_units.create.tap do |optional_unit|
          optional_unit_url_id_and_url_array.each do |optional_unit_url_id_and_url|
            url = optional_unit_url_id_and_url[:url]
            supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)
            optional_unit.optional_unit_urls.create(supplier_url: supplier_url)
          end
        end
      end

      def update_optional_unit!(optional_unit_url_id_and_url_array)
        # optional_unit_urls全て削除
        optional_unit.optional_unit_urls.delete_all
        optional_unit.tap do |optional_unit|
          optional_unit_url_id_and_url_array.each do |optional_unit_url_id_and_url|
            url = optional_unit_url_id_and_url[:url]
            supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)
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
