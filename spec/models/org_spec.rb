require 'rails_helper'

RSpec.describe Org, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:orders_to_order).through(:ec_shops) }
    it { is_expected.to have_many(:orders_to_buy).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:supplier_urls).dependent(:destroy) }
  end
end
