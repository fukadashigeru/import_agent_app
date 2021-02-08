class Supplier
  class SupplierForm
    class SupplierUrlForm < ApplicationStruct
      extend ActiveModel::Naming
      include ActiveModel::Validations

      attribute :url, Types::String.optional.default(nil)
    end
  end
end
