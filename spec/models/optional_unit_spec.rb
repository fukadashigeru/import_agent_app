require 'rails_helper'

RSpec.describe OptionalUnit, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to(:supplier) }
  end
end
