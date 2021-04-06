module Ui
  class SelectComponent < ViewComponent::Base
    def initialize(select_options, options = {}, form:, name:, **props)
      super()
      @select_options = select_options
      @options = options
      @form = form
      @name = name
      @props = props
    end
  end
end
