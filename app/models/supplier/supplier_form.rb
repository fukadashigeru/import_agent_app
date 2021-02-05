class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :order, Types.Instance(Order)
    attribute :first_priority_attr, Types::Params::Integer.optional.default(nil)
    attribute :optional_unit_forms_attrs, (
      Types::Array.of(
        Types::Hash.schema(
          optional_unit_url_id: (Types::Optional::Integer | Types::Optional::String).optional.default(nil),
          url: Types::String.default(''.freeze)
        )
      ).optional.default { [] }
    )

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
        optional_unit_forms_attrs.map.with_index do |optional_unit_forms_attr, index|
          first_priority = first_priority_attr == index
          OptionalUnitForm.new(
            ordering_org: ordering_org,
            supplier: supplier,
            order: order,
            first_priority: first_priority,
            **optional_unit_forms_attr
          )
        end
    end

    # optional_unit_forms_attrsからactual_unit_formsも生成する
    def actual_unit_form
      @actual_unit_form ||=
        ActualUnitForm.new(
          ordering_org: ordering_org, supplier: supplier, order: order, **actual_unit_form_attr
        )
    end

    private

    def actual_unit_form_attr
      @actual_unit_form_attr ||= optional_unit_forms_attrs[first_priority_attr]
    end

    def supplier_urls
      @supplier_urls ||= ordering_org.supplier_urls
    end

    def indexed_supplier_urls_map_by_id
      @indexed_supplier_urls_map_by_id ||= supplier_urls.index_by(&:id)
    end

    def first_priority_unit_id
      @first_priority_unit_id ||= supplier.first_priority_unit_id
    end

    def optional_units
      @optional_units ||= supplier.optional_units
    end

    def build_optional_unit_forms_by_record
      optional_units.map do |optional_unit|
        first_priority = optional_unit.id == first_priority_unit_id
        # 今は一つだけのはず
        optional_unit_url = optional_unit.optional_unit_urls.first
        supplier_url = indexed_supplier_urls_map_by_id[optional_unit_url.supplier_url_id]
        OptionalUnitForm.new(
          ordering_org: ordering_org,
          supplier: supplier,
          first_priority: first_priority,
          optional_unit_url_id: optional_unit_url.id,
          url: supplier_url.url
        )
      end
    end
  end
end
