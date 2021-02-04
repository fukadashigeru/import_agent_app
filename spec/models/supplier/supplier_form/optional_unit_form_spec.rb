require 'rails_helper'

RSpec.describe Supplier::SupplierForm::OptionalUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      first_priority: first_priority,
      optional_unit_url_id: optional_unit_url_id,
      url: url
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:supplier_url) { create :supplier_url, url: url, org: org }
  let(:first_priority) { false }
  let(:optional_unit_url_id) { nil }
  let(:url) { 'https://example_1.com/' }


  describe 'save_optional_unit!' do
    subject { form.save_optional_unit! }
    context 'optional_unitの生成数を確認する' do
      context 'optional_unit_url_idがある場合' do
        let(:optional_unit_url_id) { optional_unit_url.id }
        let!(:optional_unit_url) { create :optional_unit_url, optional_unit: optional_unit, supplier_url: supplier_url }
        let(:optional_unit) { create :optional_unit, supplier: supplier }
        let(:url) { 'https://example_1.com/' }
        let(:supplier_url) { create :supplier_url, org: other_org, url: url }
        let(:other_org) { create :org, org_type: :ordering_org }
        it 'optional_unitは増えない' do
          expect { subject }.to change { OptionalUnit.count }.by(0)
        end
        it 'optional_unit_urlは増えない' do
          expect { subject }.to change { OptionalUnitUrl.count }.by(0)
        end
      end
      context 'optional_unit_url_idがない場合' do
        it 'optional_unitが1つ増える' do
          expect { subject }.to change { OptionalUnit.count }.by(1)
        end
        it 'optional_unit_utlが1つ増える' do
          expect { subject }.to change { OptionalUnitUrl.count }.by(1)
        end
      end
    end
    context 'supplier_ulrの生成数を確認する' do
      context '同じurlをもつsupplier_urlがない場合' do
        before { create :supplier_url, org: other_org, url: url }
        let(:other_org) { create :org, org_type: :ordering_org }
        it 'supplierが1つ増える' do
          expect { subject }.to change { SupplierUrl.count }.by(1)
        end
      end
      context '同じurlをもつsupplier_urlがある場合' do
        before { create :supplier_url, org: org, url: url }
        it 'supplierが増えない' do
          expect { subject }.to change { SupplierUrl.count }.by(0)
        end
      end
    end
    context 'first_priorityを確認する' do
      context 'first_priorityがtrueの場合' do
        let(:first_priority) { false }
        it 'first_priority_unit_idがnil' do
          subject
          expect(supplier.first_priority_unit_id).to be_nil
        end
      end
      context 'first_priorityがfalseの場合' do
        let(:first_priority) { true }
        it 'first_priority_unit_idがnilではない' do
          subject
          expect(supplier.first_priority_unit_id).to be_present
        end
      end
    end
  end
end
