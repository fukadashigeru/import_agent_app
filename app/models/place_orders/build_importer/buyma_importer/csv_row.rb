module PlaceOrders
  class BuildImporter
    class BuymaImporter
      class CsvRow < ApplicationStruct
        attribute :row, Types.Instance(CSV::Row)

        module HeaderColumns
          ITEM_NO = '商品ID'.freeze
          TRADE_NO = '取引ID'.freeze
          TITLE = '商品名'.freeze
          POSTAL = '郵便番号'.freeze
          ADDRESS = '住所'.freeze
          NAME = '名前（本名）'.freeze
          PHONE = '電話番号'.freeze
          COLOR_SIZE = '色・サイズ'.freeze
          QUANTITY = '受注数'.freeze
          SELLING_UNIT_PRICE = '価格'.freeze
          INFORMATION = '連絡事項'.freeze
          MEMO = '受注メモ'.freeze
        end

        def item_no
          row[HeaderColumns::ITEM_NO]
        end

        def trade_no
          row[HeaderColumns::TRADE_NO]
        end

        def title
          row[HeaderColumns::TITLE]
        end

        def postal
          row[HeaderColumns::POSTAL]
        end

        def address
          row[HeaderColumns::ADDRESS]
        end

        def addressee
          row[HeaderColumns::NAME]
        end

        def phone
          row[HeaderColumns::PHONE]
        end

        def color_size
          row[HeaderColumns::COLOR_SIZE]
        end

        def quantity
          row[HeaderColumns::QUANTITY].to_i
        end

        def selling_unit_price
          row[HeaderColumns::SELLING_UNIT_PRICE].to_i
        end

        def information
          row[HeaderColumns::INFORMATION]
        end

        def memo
          row[HeaderColumns::MEMO]
        end
      end
    end
  end
end
