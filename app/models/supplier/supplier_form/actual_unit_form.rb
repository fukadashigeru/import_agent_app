class Supplier
  class SupplierForm
    class ActualUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :order, Types.Instance(Order)
      # attribute :first_priority, Types::Bool.optional.default(false)
      attribute :optional_unit_url_id, (Types::Optional::Integer | Types::Optional::String).optional.default(nil)
      # attribute :actual_unit_url_id, Types::Integer.optional.default(nil)
      attribute :url, Types::String.optional.default(''.freeze)

      def save_actual_unit!
        return if url.empty?

        if order.actual_unit
          update_actual_unit!
        else
          create_actual_unit!
        end
      end

      private

      def create_actual_unit!
        supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)

        order.create_actual_unit.tap do |actual_unit|
          actual_unit.actual_unit_urls.create(supplier_url: supplier_url)
        end
      end

      def update_actual_unit!
        supplier_url = ordering_org.supplier_urls.find_or_create_by(url: url)
        actual_unit_url = actual_unit.actual_unit_urls.first
        actual_unit_url.update(supplier_url: supplier_url)
        actual_unit_url.actual_unit
      end

      def actual_unit
        @actual_unit ||= order.actual_unit
      end
    end
  end
end
