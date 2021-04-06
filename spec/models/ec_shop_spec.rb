require 'rails_helper'

RSpec.describe EcShop, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:org) }
    it { is_expected.to have_many(:suppliers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:orders).dependent(:restrict_with_error) }
  end
end
