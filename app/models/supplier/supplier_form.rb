class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :order, Types.Instance(Order)
    attribute :first_priority_attr, Types::Params::Integer.optional.default(nil)
    attribute :optional_unit_forms_attrs_arr, Types::Array.of(
      Types::Hash.schema(
        optional_unit_id: Types::Params::Integer.optional.default(nil),
        urls: Types::Array.of(Types::String.optional.default(nil)).optional.default([].freeze)
      )
    ).optional.default([].freeze)

    def save_units!
      ApplicationRecord.transaction do
        optional_unit_forms_for_save.each(&:save_optional_unit!)
        actual_unit_form.save_actual_unit!
      end
    end

    # フォームように最低5個のoptional_unit_formを生成
    def optional_unit_forms_for_form(count: 5)
      optional_unit_forms = build_optional_unit_forms_by_record

      @optional_unit_forms_for_form ||= optional_unit_forms.tap do |forms|
        forms if forms.count >= count

        (count - forms.count).times do |_|
          forms << OptionalUnitForm.new(ordering_org: ordering_org, supplier: supplier)
        end
      end
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

    # optional_unit_forms_attrsからactual_unit_formsも生成する
    def actual_unit_form
      @actual_unit_form ||=
        ActualUnitForm.new(
          ordering_org: ordering_org,
          supplier: supplier,
          order: order,
          actual_urls: actual_urls
        )
    end

    private

    def optional_units
      @optional_units ||= supplier.optional_units
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
      raise Error if first_priority_attr.blank?

      optional_unit_forms_attrs_arr[first_priority_attr][:urls]
    end

    def indexed_supplier_urls_by_optional_unit
      @indexed_supplier_urls_by_optional_unit ||=
        optional_units.index_with do |optional_unit|
          optional_unit.optional_unit_urls.map { |optional_unit_url| optional_unit_url.supplier_url.url }
        end
    end
  end
end
