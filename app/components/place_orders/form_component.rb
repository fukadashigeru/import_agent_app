module PlaceOrders
  class FormComponent < ViewComponent::Base
    attr_reader :org, :form

    def initialize(org:, form:)
      super
      @org = org
      @form = form
    end

    def shop_type_select_options
      ShopType.to_activerecord_enum.map do |key, value|
        [(I18n.t key, scope: %i[enum shop_type]), value]
      end
    end
  end
end
