class Layout::NavbarComponent < ViewComponent::Base
  def initialize(org:, tab:)
    @org = org
    @tab = tab
  end
end
