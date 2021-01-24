class ApplicationEnum
  class << self
    def items
      @items || {}
    end

    def register(item)
      @items ||= {}

      if @items.key?(item.id)
        raise "'id'=#{item.id} is already registered."
      else
        @items[item.id] = item
      end
    end

    def to_activerecord_enum
      convert_items_to_activerecord_enum(items)
    end

    def find_by_id(id)
      items[id]
    end

    def find_item_by_key(key)
      items_by_key[key.to_sym]
    end

    def select_options
      items.map do |_, item|
        [item.name, item.key]
      end
    end

    private

    def convert_items_to_activerecord_enum(items)
      items.map do |id, item|
        [item.key, id]
      end.to_h
    end

    def items_by_key
      @items_by_key ||= items.map do |_, item|
        [item.key, item]
      end.to_h
    end
  end
end
