module PlaceOrders
  class Importer < ApplicationStruct
    attribute :io, Types.Instance(IO) | Types.Instance(Tempfile) | Types.Instance(StringIO)
    
    def call
      ApplicationRecord.transaction do
        import_orders!
      end
    end

    private

    def import_orders!
      
    end
  end
end
