module Layout
  class NavbarComponent < ViewComponent::Base
    def initialize(org: nil, tab: nil, active: nil, switch_company: false, company_detail: false)
      # TODO: orgのログイン・セッション回りを実装したら修正予定
      super()
      @org = org
      @tab = tab
      @active = active
      @switch_company = switch_company
      @company_detail = company_detail
    end

    def import_pointer_events
      'pointer-events-none' if current_page?([@org, :place_orders, :import])
    end
  end
end
