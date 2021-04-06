require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'Associations' do
    it { is_expected.to have_one(:actual_unit).dependent(:destroy) }
  end
  describe 'Validations' do
    describe 'validate :ordering_org?' do
      subject { order.tap(&:valid?).errors[:base] }
      let(:order) { build :order, ec_shop: ec_shop }
      let(:ordering_org) { create :org, org_type: org_type }
      let(:ec_shop) { create :ec_shop, org: ordering_org }
      context 'org_typeがordering_orgの場合' do
        let(:org_type) { :ordering_org }
        it { is_expected.to be_blank }
      end
      context 'org_typeがbuying_orgの場合' do
        let(:org_type) { :buying_org }
        it { is_expected.to include '発注できない会社です。' }
      end
    end
    describe 'validate :buying_org?' do
      subject { order.tap(&:valid?).errors[:base] }
      let(:order) { build :order, ordering_org: ordering_org, buying_org: buying_org }
      let(:ordering_org) { create :org, org_type: :ordering_org }
      context 'buying_orgがnilのとき' do
        let(:buying_org) { nil }
        it { is_expected.to be_blank }
      end
      context 'org_typeがordering_orgの場合' do
        let(:buying_org) { create :org, org_type: :ordering_org }
        it { is_expected.to include '買付できない会社です。' }
      end
      context 'org_typeがbuying_orgの場合' do
        let(:buying_org) { create :org, org_type: :buying_org }
        it { is_expected.to be_blank }
      end
    end
  end
  describe 'Methods' do
    describe '#status_i18n' do
      it { expect(build(:order, status: :before_order).status_i18n).to eq '1.発注前' }
      it { expect(build(:order, status: :ordered).status_i18n).to eq '2.発注済' }
      it { expect(build(:order, status: :buying).status_i18n).to eq '3.買付中' }
      it { expect(build(:order, status: :shipped).status_i18n).to eq '4.発送済' }
    end
  end
end
