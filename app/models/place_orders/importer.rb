module PlaceOrders
  class Importer < ApplicationStruct
    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    # attribute :order, Types.Instance(Order)

    BATCH_SIZE = 300

    module HeaderColumns
      TRADE_NO = '商品ID'.freeze
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

    def call
      ApplicationRecord.transaction do
        import_orders!
      end
    end

    private

    def import_orders!
      Order.import orders
    end

    def csv_string
      @csv_string ||= NKF.nkf('-xw', io.read)
    end

    def read_csv
      @read_csv ||= CSV.parse(csv_string, headers: true)
    end

    def orders
      read_csv.map do |row|
        build_order(row)
      end
    end

    def build_order(row)
      Order.new(
        trade_no: row[HeaderColumns::TRADE_NO],
        title: row[HeaderColumns::TITLE],
        postal: row[HeaderColumns::POSTAL],
        address: row[HeaderColumns::ADDRESS],
        addressee: row[HeaderColumns::NAME],
        phone: row[HeaderColumns::PHONE],
        color_size: row[HeaderColumns::COLOR_SIZE],
        quantity: row[HeaderColumns::QUANTITY].to_i,
        selling_unit_price: row[HeaderColumns::SELLING_UNIT_PRICE].to_i,
        information: row[HeaderColumns::INFORMATION].to_i,
        memo: row[HeaderColumns::MEMO].to_i,
        status: :before_order
      )
    end
  end
end
