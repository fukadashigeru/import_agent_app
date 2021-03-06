module PlaceOrders
  class BuildImporter < ApplicationStruct
    include ActiveModel::Validations

    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    attribute :ordering_org, Types.Instance(Org)
    attribute :ec_shop_type, Types::Params::Integer

    delegate :call, to: :importer

    def importer
      @importer ||= klass.new(attributes)
    end

    private

    def klass
      case ec_shop_type_key
      when :buyma
        BuymaImporter
      else
        raise NotImplementedError
      end
    end

    def ec_shop_type_key
      @ec_shop_type_key ||= EcShopType.find_by_id(ec_shop_type).key
    end
  end
end
