require 'rails_helper'

RSpec.describe SupplierUrl, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:actual_unit_urls).dependent(:destroy) }
  end
end
