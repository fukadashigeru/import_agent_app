require 'rails_helper'

RSpec.describe OptionalUnitUrl, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:supplier_url) }
    it { is_expected.to belong_to(:optional_unit) }
  end
end
