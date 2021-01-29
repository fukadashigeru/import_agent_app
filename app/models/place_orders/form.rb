module PlaceOrders
  class Form < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :shop_type, Types::Params::Integer.optional.default(nil)
    attribute :csv_file, Types::Instance(ActionDispatch::Http::UploadedFile).optional.default(nil)

    # validates :shop_type, presence: true
    # validates :csv_file, presence: true
    validate :validate_shop_type_presence
    validate :validate_csv_file_presence

    # shop_typeをすべて対応するまでのvalidate
    validate :validate_shop_type, if: :shop_type

    # こんなコードでいい？？
    validate :vaildate_csv_header, if: :csv_file

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

    # def import!
    #   build_importer.call
    # end

    def build_importer
      @build_importer ||= PlaceOrders::BuildImporter.new(
        io: io,
        ordering_org: ordering_org,
        shop_type: shop_type
      ).importer
    end

    private

    def csv_string
      @csv_string ||= NKF.nkf('-xw', csv_file.read)
    end

    def csv
      @csv ||= CSV.parse(csv_string, headers: true, liberal_parsing: true)
    end

    def csv_headers
      @csv_headers ||= csv.headers
    end

    # def csv_headers
    #   @csv_headers ||= CSV.parse(csv_string, headers: false, liberal_parsing: true).first
    # end

    def io
      StringIO.new(csv_string)
    end

    def validate_shop_type_presence
      errors.add(:base, :shop_type_required) if !shop_type
    end

    def validate_csv_file_presence
      errors.add(:base, :csv_file_required) if !csv_file
    end

    def validate_shop_type
      return if shop_type_key == :buyma

      errors.add(:base, :invalid_shop_type)
    end

    def vaildate_csv_header
      if shop_type
        case shop_type_key
        when :buyma
          if !BUYMA_HEADERS_ELE_REQUIRED.to_set.subset?(csv_headers.to_set)
            errors.add(:base, :csv_header_lack)
          end
        end
      end
    end

    def shop_type_key
      @shop_type_key ||= ShopType.find_by_id(shop_type).key
    end
  end
end
