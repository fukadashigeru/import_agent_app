module PlaceOrders
  class Form < ApplicationStruct
    extend ActiveModel::Naming

    attribute :org, Types.Instance(Org)
    # attribute :shop_type_id, Types::Params::Integer
    attribute :csv_file, Types::Instance(ActionDispatch::Http::UploadedFile).optional.default(nil)

    def import!
      importer.call
    end

    private

    def importer
      @importer ||= PlaceOrders::Importer.new(
        io: csv_file.tempfile
      )
    end

    def csv_string
      @csv_string ||= NKF.nkf('-xw', csv_file.read)
    end
  end
end
