class Supplier
  class Form < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :shop_type, Types::Params::Integer

    def save!
    end

    private

  end
end
