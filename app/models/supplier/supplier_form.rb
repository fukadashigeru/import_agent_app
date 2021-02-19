class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :order, Types.Instance(Order)
    attribute :first_priority_attr, Types::Params::Integer.optional.default(nil)
    attribute :actual_first_priority_attr, Types::Params::Integer.optional.default(nil)
    attribute :optional_unit_forms_attrs_arr, Types::Array.of(
      Types::Hash.schema(
        optional_unit_id: Types::Params::Integer.optional.default(nil),
        urls: Types::Array.of(Types::String.optional.default(nil)).optional.default([].freeze)
      )
    ).optional.default([].freeze)

    delegate :optional_units, to: :supplier
    delegate :actual_unit, to: :order

    validate :valid_order_having_no_actual?, unless: :actual_first_priority_attr

    def valid_order_having_no_actual?
      return if indexed_supplier_orders_by_id.key?(order)

      errors.add(:base, '不正な注文のため操作が取り消されました。')
    end

    def upsert_or_destroy_units!
      ApplicationRecord.transaction do
        optional_unit_forms_for_save.each(&:upsert_or_destroy!)
        actual_unit_forms_for_save.each(&:upsert_actual_unit!)
      end
    end

    # フォームように最低5個のoptional_unit_formを生成
    def optional_unit_forms_for_form(count: 5)
      optional_unit_forms = build_optional_unit_forms_by_record

      optional_unit_forms = build_optional_unit_forms_from_actual_unit(optional_unit_forms)

      @optional_unit_forms_for_form ||= build_optional_unit_forms_for_adjustment(optional_unit_forms, count)
    end

    # create処理内などで保存できるoptional_unit_formを生成
    def optional_unit_forms_for_save
      @optional_unit_forms_for_save ||=
        optional_unit_forms_attrs_arr.map.with_index do |optional_unit_form_hash, index|
          next if not_build_optional_unit_form(optional_unit_form_hash)

          optional_unit_id = optional_unit_form_hash[:optional_unit_id]
          first_priority = first_priority_attr == index
          optional_urls = optional_unit_form_hash[:urls]

          OptionalUnitForm.new(
            ordering_org: ordering_org,
            supplier: supplier,
            optional_unit_id: optional_unit_id,
            first_priority: first_priority,
            optional_urls: optional_urls
          )
        end.compact
    end

    private

    def actual_unit_forms_for_save
      @actual_unit_forms_for_save ||=
        if actual_unit
          [].tap do |arr|
            arr << ActualUnitForm.new(
              ordering_org: ordering_org,
              supplier: supplier,
              order: order,
              actual_urls: actual_urls
            )
          end
        else
          supplier_orders.map do |supplier_order|
            ActualUnitForm.new(
              ordering_org: ordering_org,
              supplier: supplier,
              order: supplier_order,
              actual_urls: actual_urls
            )
          end
        end
    end

    def build_optional_unit_forms_by_record
      optional_units.map do |optional_unit|
        first_priority = optional_unit.id == supplier.first_priority_unit_id
        optional_urls = indexed_supplier_urls_by_optional_unit[optional_unit]
        OptionalUnitForm.new(
          ordering_org: ordering_org,
          supplier: supplier,
          optional_unit_id: optional_unit.id,
          first_priority: first_priority,
          optional_urls: optional_urls
        )
      end
    end

    def build_optional_unit_forms_from_actual_unit(optional_unit_forms)
      optional_unit_forms.tap do |forms|
        if actual_unit && !optional_urls_hash.key?(actual_urls_by_record)
          actual_supplier_urls = order.actual_unit.supplier_urls.map(&:url)
          forms << OptionalUnitForm.new(
            ordering_org: ordering_org,
            supplier: supplier, optional_urls:
            actual_supplier_urls
          )
        end
      end
    end

    def build_optional_unit_forms_for_adjustment(optional_unit_forms, count)
      optional_unit_forms.tap do |forms|
        forms if forms.count >= count

        (count - forms.count).times do |_|
          forms << OptionalUnitForm.new(ordering_org: ordering_org, supplier: supplier)
        end
      end
    end

    def not_build_optional_unit_form(optional_unit_form_hash)
      optional_unit_id = optional_unit_form_hash[optional_unit_id]
      urls = optional_unit_form_hash[:urls]
      array = []
      array << optional_unit_id.blank?
      urls.each_with_object(array) do |url, arr|
        arr << url.blank?
      end
      array.all?(true)
    end

    def actual_urls
      if actual_first_priority_attr
        optional_unit_forms_attrs_arr[actual_first_priority_attr][:urls]
      else
        raise Error if first_priority_attr.blank?

        optional_unit_forms_attrs_arr[first_priority_attr][:urls]
      end
    end

    def indexed_supplier_urls_by_optional_unit
      @indexed_supplier_urls_by_optional_unit ||=
        optional_units.index_with do |optional_unit|
          optional_unit.optional_unit_urls.map { |optional_unit_url| optional_unit_url.supplier_url.url }
        end
    end

    def optional_urls_map_by_record
      @optional_urls_map_by_record ||=
        optional_units.map do |optional_unit|
          optional_unit.supplier_urls.map(&:url)
        end
    end

    def actual_urls_by_record
      @actual_urls_by_record ||= actual_unit.supplier_urls.map(&:url)
    end

    def optional_urls_hash
      @optional_urls_hash ||= optional_urls_map_by_record.index_with('')
    end

    def supplier_orders
      @supplier_orders ||= supplier.orders.before_order.having_no_actual_unit
    end

    def indexed_supplier_orders_by_id
      @indexed_supplier_orders_by_id ||= supplier_orders.index_with('')
    end
  end
end
