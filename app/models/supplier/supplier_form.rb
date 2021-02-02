class Supplier
  class SupplierForm < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :supplier, Types.Instance(Supplier)
    attribute :optional_unit_forms_attrs, (
      Types::Array.of(
        Types::Hash.schema(
          first_priority: Types::Params::Bool.default(false),
          optional_unit_url_id: Types::Params::Integer.optional.default(nil),
          url: Types::String
        )
      ).optional.default { {} }
    )

    def call!
      ApplicationRecord.transaction do
        create_optional_units!
      end
    end

    def optional_unit_forms(count: 5)
      optional_unit_forms = optional_unit_forms_attrs.map do |optional_unit_forms_attr|
        OptionalUnitForm.new(ordering_org: ordering_org, supplier: supplier, **optional_unit_forms_attr)
      end

      @optional_unit_forms ||= optional_unit_forms.tap do |this_map|
        this_map if this_map.count >= count

        (count - this_map.count).times do |_|
          this_map << OptionalUnitForm.new(ordering_org: ordering_org, supplier: supplier)
        end
      end
    end

    private

    def create_optional_units!
      optional_unit_forms.each(&:call!)
    end
  end
end
