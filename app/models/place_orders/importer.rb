module PlaceOrders
  class Importer < ApplicationStruct
    include ActiveModel::Validations

    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    attribute :ordering_org, Types.Instance(Org)

    validate :orders_empty

    BATCH_SIZE = 300

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

    def call
      return false if invalid?

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
      @read_csv ||= CSV.parse(csv_string, headers: true, liberal_parsing: true)
    end

    def orders
      @orders ||= read_csv.map do |row|
        build_order(row) if !order_trade_no_hash.key?(row[HeaderColumns::TRADE_NO])
      end.compact
    end

    def build_order(row)
      Order.new(
        item_no: row[HeaderColumns::ITEM_NO],
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
        status: :before_order,
        ordering_org: ordering_org
      )
    end

    def order_trade_no_hash
      @order_trade_no_hash ||= Order.all.index_by(&:trade_no)
    end

    def orders_empty
      errors.add(:base, '新しくインポートできる注文はありません。') if orders.empty?
    end
  end
end
