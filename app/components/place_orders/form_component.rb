module PlaceOrders
  class FormComponent < ViewComponent::Base
    attr_reader :org, :form

    def initialize(org:, form:)
      super()
      @org = org
      @form = form
    end

    def ec_shop_type_select_options
      EcShopType.to_activerecord_enum.map do |key, _|
        [(I18n.t key, scope: %i[enum ec_shop_type]), key]
      end
    end

    def disabled_shop_type
      EcShopType.to_activerecord_enum.map do |key, _|
        key if key.in? %i[default amazon]
      end
    end
  end
end
