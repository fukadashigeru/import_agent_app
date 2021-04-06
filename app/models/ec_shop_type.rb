class EcShopType < ApplicationEnum
  class EnumItem < ApplicationEnumItem
    def name
      I18n.t key, scope: %i[enum accounting_softwares items]
    end
  end
end

# ImportAgent専用
EcShopType.register EcShopType::EnumItem.new(
  id: 1,
  key: :default
)

# Amazon
EcShopType.register EcShopType::EnumItem.new(
  id: 2,
  key: :amazon
)

# BUYMA
EcShopType.register EcShopType::EnumItem.new(
  id: 3,
  key: :buyma
)
