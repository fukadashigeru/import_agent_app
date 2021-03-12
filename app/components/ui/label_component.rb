module Ui
  class LabelComponent < ViewComponent::Base
    def initialize(form:, name:)
      super()
      @form = form
      @name = name
    end
  end
end
