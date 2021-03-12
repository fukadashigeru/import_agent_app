module Ui
  class FieldsetComponent < ViewComponent::Base
    with_content_areas :title, :subtext, :actions

    def initialize(first: true)
      super()
      @first = first
    end
  end
end
