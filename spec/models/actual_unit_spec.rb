require 'rails_helper'

RSpec.describe ActualUnit, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to have_many(:actual_unit_urls) }
  end
end

