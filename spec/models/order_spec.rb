require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'Methods' do
    describe '#status_i18n' do
      it { expect(build(:order, status: :before_order).status_i18n).to eq '1.発注前' }
      it { expect(build(:order, status: :ordered).status_i18n).to eq '2.発注済' }
      it { expect(build(:order, status: :buying).status_i18n).to eq '3.買付中' }
      it { expect(build(:order, status: :shipped).status_i18n).to eq '4.発送済' }
    end
  end
end
