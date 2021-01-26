require 'rails_helper'

RSpec.describe ActualUnitUrl, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:supplier_url) }
    it { is_expected.to belong_to(:actual_unit) }
  end
end
