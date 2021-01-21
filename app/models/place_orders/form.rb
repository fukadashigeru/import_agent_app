module PlaceOrders
  class Form < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :org, Types.Instance(Org)
    attribute :shop_type, Types::Params::Integer.optional.default(nil)
    attribute :csv_file, Types::Instance(ActionDispatch::Http::UploadedFile).optional.default(nil)

    validates :shop_type, presence: true
    validates :csv_file, presence: true

    # こんなコードでいい？？
    validate :vaildate_csv_header, if: :shop_type && :csv_file

    # BUYMAの場合のヘッダーの必須項目
    BUYMA_HEADERS_ELE_REQUIRED = %w[
      商品ID
      取引ID
      商品名
      郵便番号
      住所
      名前（本名）
      電話番号
      色・サイズ
      受注数
      価格
      連絡事項
      受注メモ
    ].freeze

    def import!
      importer.call
    end

    def importer
      @importer ||= PlaceOrders::Importer.new(
        io: csv_file.tempfile
      )
    end

    private

    def csv_string
      @csv_string ||= NKF.nkf('-xw', csv_file.read)
    end

    def header_row
      @header_row ||= CSV.parse(csv_string, headers: false).first
    end

    def vaildate_csv_header
      case ShopType.find_by_id(shop_type).key
      when :buyma
        if !BUYMA_HEADERS_ELE_REQUIRED.to_set.subset?(header_row.to_set)
          errors.add(:base, 'ファイルのヘッダー項目に不足があります。')
        end
      end
    end
  end
end
