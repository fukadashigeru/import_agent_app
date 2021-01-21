class ShopType < ApplicationEnum
  class EnumItem < ApplicationEnumItem
    def name
      I18n.t key, scope: %i[enum accounting_softwares items]
    end
  end
end

# ImportAgent専用
ShopType.register ShopType::EnumItem.new(
  id: 1,
  key: :default
)

# Amazon
ShopType.register ShopType::EnumItem.new(
  id: 2,
  key: :amazon
)

# BUYMA
ShopType.register ShopType::EnumItem.new(
  id: 3,
  key: :buyma
)
