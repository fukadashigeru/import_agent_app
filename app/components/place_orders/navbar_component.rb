module PlaceOrders
  class NavbarComponent < ViewComponent::Base
    def initialize(org:, active:)
      super
      @org = org
      @active = active
    end

    def active_class
      'inline-flex items-center px-1 pt-1 border-b-2 border-indigo-500 text-sm font-medium
      leading-5 text-gray-900 focus:outline-none focus:border-indigo-700 transition duration-150
      ease-in-out cursor-not-allowed pointer-events-none'
    end

    def inactive_class
      'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700
      inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium'
    end
  end
end
