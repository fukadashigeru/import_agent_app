class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :order, Types.Instance(Order)
    attribute :optional_unit_forms_attrs, (
      Types::Array.of(
        Types::Hash.schema(
          first_priority: Types::Params::Bool.default(false),
          optional_unit_url_id: Types::Params::Integer.optional.default(nil),
          url: Types::String.default(''.freeze)
        )
      ).optional.default { {} }
    )

    def save_units!
      ApplicationRecord.transaction do
        optional_unit_forms.each(&:save_optional_unit!)
        actual_unit_form.save_actual_unit!
      end
    end

    # デフォルトのoptional_unit_formsを生成
    def optional_unit_forms(count: 5)
      optional_unit_forms = optional_unit_forms_attrs.map do |optional_unit_forms_attr|
        OptionalUnitForm.new(
          ordering_org: ordering_org,
          supplier: supplier,
          order: order,
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
      @actual_unit_form_attr ||= {}.tap do |actual_unit_forms_attr|
        optional_unit_forms_attrs.each do |optional_unit_forms_attr|
          actual_unit_forms_attr.merge!(
            optional_unit_forms_attr
          ) if optional_unit_forms_attr[:first_priority]
        end
      end.reject{ |k, v| k == :first_priority }
    end
  end
end
