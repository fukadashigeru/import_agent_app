class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :first_priority_attr, Types::Params::Integer.optional.default(nil)
    attribute :order_ids, Types::Array.of(Types::Params::Integer) | Types::Params::Symbol
    attribute :optional_unit_forms_attrs_arr, Types::Array.of(
      Types::Hash.schema(
        optional_unit_id: Types::Params::Integer.optional.default(nil),
        urls: Types::Array.of(Types::String.optional.default(nil)).optional.default([].freeze)
      )
    ).optional.default([].freeze)

    delegate :optional_units, to: :supplier
    delegate :orders, to: :supplier
    # delegate :actual_unit, to: :order

    validate :valid_order_having_no_actual, unless: :actual_first_priority_attr
    validate :valid_optional_units_belong_to_supplier

    FORM_COUNT = 5

    def upsert_or_destroy_units!
      ApplicationRecord.transaction do
        valid_optional_unit_forms.each(&:upsert_or_destroy!)
        actual_unit_forms.each(&:upsert_actual_unit!)
      end
    end

    # フォーム用に最低5個のoptional_unit_formを生成
    def optional_unit_forms
      count = optional_units.count > FORM_COUNT ? optional_units.count : FORM_COUNT
      @optional_unit_forms ||= buid_forms(count)
    end

    private

    # パラメータから保存前の有効なOptionalUnitFormをbuildする
    def valid_optional_unit_forms
      @valid_optional_unit_forms ||=
        optional_unit_forms_attrs_arr.map.with_index do |optional_unit_form_hash, index|

          optional_unit_id = optional_unit_form_hash[:optional_unit_id]
          first_priority = first_priority_attr == index
          optional_urls = optional_unit_form_hash[:urls]

          build_unit_form(
            optional_unit_id: optional_unit_id,
            first_priority: first_priority,
            optional_urls: optional_urls
          )
        end.reject(&:blank_form?)
    end

    # OptionalUnitFormをcountだけbuildする
    def buid_forms(count)
      Array.new(count).map.with_index do |_, i|
        if optional_units[i]
          build_unit_form_from_optional_unit(optional_units[i])
        else
          build_unit_form
        end
      end
    end

    # OptionalUnitからOptionalUnitFormを生成する
    def build_unit_form_from_optional_unit(optional_unit)
      first_priority = optional_unit.id == supplier.first_priority_unit_id
      optional_urls = indexed_supplier_urls_by_optional_unit[optional_unit]

      build_unit_form(
        optional_unit_id: optional_unit.id,
        first_priority: first_priority,
        optional_urls: optional_urls
      )
    end

    # OptionalUnitFormをbuildする
    def build_unit_form(optional_unit_id: nil, first_priority: nil, optional_urls: nil)
      OptionalUnitForm.new(
        ordering_org: ordering_org,
        supplier: supplier,
        optional_unit_id: optional_unit_id,
        first_priority: first_priority,
        optional_urls: optional_urls
      )
    end

    def actual_unit_forms
      if order_ids == :all
        orders.map do |order|
          ActualUnitForm.new(
            ordering_org: ordering_org,
            supplier: supplier,
            order: order,
            actual_urls: actual_urls
          )
        end
      else
        order_ids.map do |order_id|
          order = indexed_orders_by_id[order_id]
          next unless order

          ActualUnitForm.new(
            ordering_org: ordering_org,
            supplier: supplier,
            order: order,
            actual_urls: actual_urls
          )
        end
      end
    end

    def actual_urls
      optional_unit_forms_attrs_arr[first_priority_attr][:urls]
    end

    def indexed_orders_by_id
      @indexed_orders_by_id ||= supplier.orders.index_by(&:id)
    end

    # def build_unit_form_from_actual_unit(actual_unit)
    #   return nil if optional_urls_hash.key?(actual_urls_by_record)

    #   actual_supplier_urls = actual_unit.supplier_urls.map(&:url)
    #   OptionalUnitForm.new(
    #     ordering_org: ordering_org,
    #     supplier: supplier,
    #     optional_urls: actual_supplier_urls
    #   )
    # end

    # def actual_urls
    #   if actual_first_priority_attr
    #     optional_unit_forms_attrs_arr[actual_first_priority_attr][:urls]
    #   else
    #     raise Error if first_priority_attr.blank?

    #     optional_unit_forms_attrs_arr[first_priority_attr][:urls]
    #   end
    # end

    def indexed_supplier_urls_by_optional_unit
      @indexed_supplier_urls_by_optional_unit ||=
        optional_units.index_with do |optional_unit|
          optional_unit.optional_unit_urls.map { |optional_unit_url| optional_unit_url.supplier_url.url }
        end
    end

    # def optional_urls_map_by_record
    #   @optional_urls_map_by_record ||=
    #     optional_units.map do |optional_unit|
    #       optional_unit.supplier_urls.map(&:url)
    #     end
    # end

    # def actual_urls_by_record
    #   @actual_urls_by_record ||= actual_unit.supplier_urls.map(&:url)
    # end

    # def optional_urls_hash
    #   @optional_urls_hash ||= optional_urls_map_by_record.index_with('')
    # end

    # def supplier_orders
    #   @supplier_orders ||= supplier.orders.before_order.having_no_actual_unit
    # end

    # def indexed_supplier_orders_by_id
    #   @indexed_supplier_orders_by_id ||= supplier_orders.index_with('')
    # end

    # def valid_order_having_no_actual
    #   return if indexed_supplier_orders_by_id.key?(order)

    #   errors.add(:base, '不正な注文のため操作が取り消されました。')
    # end

    # def valid_optional_units_belong_to_supplier
    #   return if check_all_optional_unit_belong_to_supplier

    #   errors.add(:base, '不正な買付先のため操作が取り消されました。')
    # end

    # def check_all_optional_unit_belong_to_supplier
    #   optional_unit_ids.all? do |optional_unit_id|
    #     supplier.optional_units.index_by(&:id).key?(optional_unit_id)
    #   end
    # end

    # def optional_unit_ids
    #   @optional_unit_ids ||= optional_unit_forms_attrs_arr.pluck(:optional_unit_id).compact
    # end
  end
end
