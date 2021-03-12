require 'rails_helper'

RSpec.describe Supplier, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:ec_shop) }
  end
end
