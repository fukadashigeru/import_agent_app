class EmailValidator < ActiveModel::EachValidator
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_EMAIL_LENGTH = 320

  def validate_each(record, attribute, value)
    record.errors.add(attribute) unless valid?(value)
  end

  private

  def valid?(value)
    value =~ VALID_EMAIL_REGEX && value.length <= MAX_EMAIL_LENGTH
  end
end
