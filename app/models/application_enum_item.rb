class ApplicationEnumItem < ApplicationStruct
  attribute :id, Types::Integer
  attribute :key, Types::Strict::Symbol

  def name
    raise NotImplementedError
  end
end
