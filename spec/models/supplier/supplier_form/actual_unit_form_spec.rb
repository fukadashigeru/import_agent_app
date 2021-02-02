require 'rails_helper'

RSpec.describe Supplier::SupplierForm::ActualUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      order: order,
      optional_unit_url_id: optional_unit_url_id,
      actual_unit_url_id: actual_unit_url_id,
      url: url
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:order) { create :order, ordering_org: org, supplier: supplier }
  let(:optional_unit_url_id) { nil }
  let(:actual_unit_url_id) { nil }
  let(:url) { 'https://example_1.com/' }
  # let(:supplier_url) { create :supplier_url, url: url, org: org }


  describe 'save_actual_unit!' do
    subject { form.save_actual_unit! }
    context 'actual_unit_url_idがない場合' do
      context 'supplier_urlがない場合' do
        it 'supplier_urlが1個増える' do
          expect { subject }.to change { org.supplier_urls.count }.by(1)
        end
        it 'actual_unit_urlが1個増える' do
          expect { subject }.to change { ActualUnitUrl.count }.by(1)
        end
      end
      context 'supplier_urlが既にある場合' do
        let!(:supplier_url) { create :supplier_url, url: url, org: org }
        it 'supplier_urlが増えない' do
          expect { subject }.to change { org.supplier_urls.count }.by(0)
        end
        it 'actual_unit_urlが1個増える' do
          expect { subject }.to change { ActualUnitUrl.count }.by(1)
        end
      end
    end
    context 'actual_unit_url_idがある場合' do
      let!(:actual_unit_url_id) { actual_unit_url.id }
      let(:actual_unit_url) { create :actual_unit_url, actual_unit: actual_unit }
      let(:actual_unit) { create :actual_unit, order: order }
      context 'supplier_urlがない場合' do
        it 'supplier_urlが1個増える' do
          expect { subject }.to change { org.supplier_urls.count }.by(1)
        end
        it 'actual_unit_urlは増えない' do
          expect { subject }.to change { ActualUnitUrl.count }.by(0)
        end
      end
      context 'supplier_urlが既にある場合' do
        let!(:supplier_url) { create :supplier_url, url: url, org: org }
        it 'supplier_urlが増えない' do
          expect { subject }.to change { org.supplier_urls.count }.by(0)
        end
        it 'actual_unit_urlは増えない' do
          expect { subject }.to change { ActualUnitUrl.count }.by(0)
        end
      end
    end
  end
end
