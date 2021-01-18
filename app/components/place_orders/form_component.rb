module PlaceOrders
  class FormComponent < ViewComponent::Base
    attr_reader :org, :form

    def initialize(org:, form:)
      super
      @org = org
      @form = form
    end
  end
end
