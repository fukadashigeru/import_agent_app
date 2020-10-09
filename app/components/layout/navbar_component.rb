class Layout::NavbarComponent < ViewComponent::Base
  def initialize(org:, tab:)
    # TODO: orgのログイン・セッション回りを実装したら修正予定
    @org = org ? org : Org.first
    @tab = tab
  end
end
