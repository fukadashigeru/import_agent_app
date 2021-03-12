module PlaceOrders
  class BuildImporter < ApplicationStruct
    include ActiveModel::Validations

    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    attribute :ordering_org, Types.Instance(Org)
    attribute :ec_shop_type, Types::Params::Symbol.optional
                                                  .default(nil)
                                                  .enum(*EcShopType.to_activerecord_enum.keys)

    delegate :call, to: :importer

    def importer
      @importer ||= klass.new(attributes)
    end

    private

    def klass
      case ec_shop_type
      when :buyma
        BuymaImporter
      else
        raise NotImplementedError
      end
    end
  end
end
