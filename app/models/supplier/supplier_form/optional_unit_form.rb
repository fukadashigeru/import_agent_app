class Supplier
  class SupplierForm
    class OptionalUnitForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :ordering_org, Types.Instance(Org)
      attribute :supplier, Types.Instance(Supplier)
      attribute :optional_unit_id, Types::Integer.optional.default(nil)
      attribute :first_priority, Types::Bool.optional.default(false)
      attribute :optional_urls, Types::Array.of(Types::String).optional.default([''].freeze)

      def upsert_or_destroy!
        if optional_unit_id && optional_urls_all_blank?
          destroy_optional_unit!
        else
          upsert_optional_unit!
        end
      end

      def supplier_forms
        @supplier_forms =
          optional_urls.map do |optional_url|
            SupplierUrlForm.new(
              url: optional_url
            )
          end
      end

      private

      def destroy_optional_unit!
        if first_priority
          raise '第1優先で選択できません。'
        else
          pre_optional_unit.destroy
        end
      end

      def upsert_optional_unit!
        post_optional_unit =
          if pre_optional_unit
            update_optional_unit!
          else
            create_optional_unit!
          end

        post_optional_unit.tap do |unit|
          assign_first_priority(unit) if first_priority
        end
      end

      def create_optional_unit!
        supplier.optional_units.create.tap do |optional_unit|
          optional_urls.each do |optional_url|
            next if optional_url.blank?

            supplier_url = ordering_org.supplier_urls.find_or_create_by(url: optional_url)
            optional_unit.optional_unit_urls.create(supplier_url: supplier_url)
          end
        end
      end

      def update_optional_unit!
        # optional_unit_urls全て削除
        pre_optional_unit.optional_unit_urls.delete_all
        # 新しいoptional_unit_urlsを作成
        pre_optional_unit.tap do |unit|
          optional_urls.each do |optional_url|
            next if optional_url.blank?

            supplier_url = ordering_org.supplier_urls.find_or_create_by(url: optional_url)
            unit.optional_unit_urls.create(supplier_url: supplier_url)
          end
        end
      end

      def assign_first_priority(optional_unit)
        supplier.update(first_priority_unit_id: optional_unit.id)
      end

      def pre_optional_unit
        @pre_optional_unit ||= supplier.optional_units.find_by(id: optional_unit_id)
      end

      def optional_urls_all_blank?
        optional_urls.map(&:blank?).all?(true)
      end
    end
  end
end
