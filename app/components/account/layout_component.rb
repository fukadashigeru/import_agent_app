module Account
  class LayoutComponent < ViewComponent::Base
    with_content_areas :title, :subtext
  end
end