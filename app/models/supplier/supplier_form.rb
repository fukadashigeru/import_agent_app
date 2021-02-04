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
          optional_unit_url_id: Types::Params::Integer.optional.default(nil),
          url: Types::String.default(''.freeze)
        )
      ).optional.default { [] }
    )

    def save_units!
      ApplicationRecord.transaction do
        optional_unit_forms.each(&:save_optional_unit!)
        actual_unit_form.save_actual_unit!
      end
    end

    # デフォルトのoptional_unit_formsを生成
    def optional_unit_forms(count: 5)
      optional_unit_forms = optional_unit_forms_attrs.map.with_index do |optional_unit_forms_attr, index|
        first_priority = first_priority_attr == index ? true : false
        OptionalUnitForm.new(
          ordering_org: ordering_org,
          supplier: supplier,
          order: order,
          first_priority: first_priority,
          **optional_unit_forms_attr
        )
      end

      @optional_unit_forms ||= optional_unit_forms.tap do |this_map|
        this_map if this_map.count >= count

        (count - this_map.count).times do |_|
          this_map << OptionalUnitForm.new(ordering_org: ordering_org, supplier: supplier, order: order)
        end
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
  end
end
