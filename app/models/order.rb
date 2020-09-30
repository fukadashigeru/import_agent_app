class Order < ApplicationRecord
  enum status: { before_order: 1, ordered: 2, buying: 3, shipped: 4 }
end
