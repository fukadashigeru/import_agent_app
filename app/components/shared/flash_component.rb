module Shared
  class FlashComponent < ViewComponent::Base
    def initialize(flash)
      super()
      @flash = flash
    end

    private

    NOTIFICATION_STYLE_CLASSES = {
      info: 'notification-blue',
      success: 'notification-green',
      danger: 'notification-red'
    }.freeze

    ICON_CLASSES = {
      info: 'fa-info-circle',
      success: 'fa-check-circle',
      danger: 'fa-exclamation-circle'
    }.freeze

    def notification_style_class(key)
      NOTIFICATION_STYLE_CLASSES[key.to_sym]
    end

    def fa_icon_class(key)
      ICON_CLASSES[key.to_sym]
    end

    def get_id(index)
      "flash-message-#{index}"
    end
  end
end
