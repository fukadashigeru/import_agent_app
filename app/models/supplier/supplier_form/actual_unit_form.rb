class Supplier
  class SupplierForm
    class ActualUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :order, Types.Instance(Order)
      attribute :actual_urls, Types::Array.of(Types::String.optional.default(nil)).optional.default([])

      delegate :actual_unit, to: :order

      def save_actual_unit!
        if actual_unit
          update_actual_unit!
        else
          create_actual_unit!
        end
      end

      private

      def create_actual_unit!
        order.create_actual_unit.tap do |actual_unit|
          actual_urls.each do |actual_url|
            next if actual_url.blank?

            supplier_url = ordering_org.supplier_urls.find_or_create_by(url: actual_url)
            actual_unit.actual_unit_urls.create(supplier_url: supplier_url)
          end
        end
      end

      def update_actual_unit!
        # optional_unit_urls全て削除
        actual_unit.actual_unit_urls.delete_all

        actual_urls.each do |actual_url|
          next if actual_url.blank?

          supplier_url = ordering_org.supplier_urls.find_or_create_by(url: actual_url)
          actual_unit.actual_unit_urls.create(supplier_url: supplier_url)
        end
      end
    end
  end
end
