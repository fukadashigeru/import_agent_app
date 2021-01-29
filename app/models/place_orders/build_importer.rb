module PlaceOrders
  class BuildImporter < ApplicationStruct
    include ActiveModel::Validations

    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    attribute :ordering_org, Types.Instance(Org)
    attribute :shop_type, Types::Params::Integer

    delegate :call, to: :importer

    def importer
      @importer ||= klass.new(attributes)
    end

    private

    def klass
      case shop_type_key
      when :buyma
        BuymaImporter
      else
        raise NotImplementedError
      end
    end

    def shop_type_key
      @shop_type_key ||= ShopType.find_by_id(shop_type).key
    end
  end
end
