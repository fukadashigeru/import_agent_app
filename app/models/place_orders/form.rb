module PlaceOrders
  class Form < ApplicationStruct
    extend ActiveModel::Naming
    include ActiveModel::Validations

    attribute :ordering_org, Types.Instance(Org)
    attribute :ec_shop_type, Types::Params::Integer.optional.default(nil)
    attribute :csv_file, Types::Instance(ActionDispatch::Http::UploadedFile).optional.default(nil)

    validate :validate_ec_shop_type_presence
    validate :validate_csv_file_presence

    # ec_shop_typeをすべて対応するまでのvalidate
    validate :validate_ec_shop_type, if: :ec_shop_type

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

    def build_importer
      @build_importer ||= PlaceOrders::BuildImporter.new(
        io: io,
        ordering_org: ordering_org,
        ec_shop_type: ec_shop_type
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

    def io
      StringIO.new(csv_string)
    end

    def validate_ec_shop_type_presence
      errors.add(:base, :ec_shop_type_required) if !ec_shop_type
    end

    def validate_csv_file_presence
      errors.add(:base, :csv_file_required) if !csv_file
    end

    def validate_ec_shop_type
      return if ec_shop_type_key == :buyma

      errors.add(:base, :invalid_ec_shop_type)
    end

    def vaildate_csv_header
      case ec_shop_type_key
      when :buyma
        errors.add(:base, :csv_header_lack) if !BUYMA_HEADERS_ELE_REQUIRED.to_set.subset?(csv_headers.to_set)
      end
    end

    def ec_shop_type_key
      @ec_shop_type_key ||= EcShopType.find_by_id(ec_shop_type)&.key
    end
  end
end
