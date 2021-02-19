require 'rails_helper'

RSpec.describe Supplier::SupplierForm::ActualUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      order: order,
      actual_urls: actual_urls
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:order) { create :order, ordering_org: org, supplier: supplier, status: :before_order }
  let(:actual_urls) { [''] }

  def create_actual_unit(order, urls)
    actual_unit = (create :actual_unit, order: order)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :actual_unit_url, supplier_url: supplier_url, actual_unit: actual_unit
    end
    actual_unit
  end

  describe 'upsert_actual_unit!' do
    subject { form.upsert_actual_unit! }
    context '新規作成の場合' do
      let(:actual_urls) { ['https://example_A.com/', 'https://example_B.com/'] }
      context 'ActualUnitを確認' do
        it do
          expect { subject }.to change { ActualUnit.count }.by(1)
        end
        it do
          subject
          actual_unit = ActualUnit.last
          expect(actual_unit.order).to eq order
        end
      end
      context 'ActualUnitUrlを確認' do
        it 'ActualUnitUrlが2個増える' do
          expect { subject }.to change { ActualUnitUrl.count }.from(0).to(2)
        end
        it 'このactual_unitに紐づくactual_unit_urlは2個' do
          subject
          expect(order.actual_unit.actual_unit_urls.count).to eq 2
        end
      end
      context 'SupplierUrlを確認' do
        context 'supplier_urlがない場合' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(0).to(2)
          end
          it 'このactual_unitに紐づくsupplier_urlは2個' do
            subject
            expect(order.actual_unit.supplier_urls.count).to eq 2
          end
          it 'actual_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(order.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
        context 'supplier_urlがある場合' do
          before { create :supplier_url, org: org, url: 'https://example_A.com/' }
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(1).to(2)
          end
          it 'このactual_unitに紐づくsupplier_urlは2個' do
            subject
            expect(order.actual_unit.supplier_urls.count).to eq 2
          end
          it 'actual_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(order.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
      end
    end

    context '更新の場合' do
      let(:actual_urls) { ['https://example_A.com/', 'https://example_B.com/'] }
      before { create_actual_unit(order, ['https://example_a.com/']) }
      context 'ActualUnitを確認' do
        it do
          expect { subject }.to change { ActualUnit.count }.by(0)
        end
        it do
          subject
          actual_unit = ActualUnit.last
          expect(actual_unit.order).to eq order
        end
      end
      context 'ActualUnitUrlを確認' do
        it 'ActualUnitUrlが2個増える' do
          expect { subject }.to change { ActualUnitUrl.count }.from(1).to(2)
        end
        it 'このactual_unitに紐づくactual_unit_urlは2個' do
          subject
          expect(order.actual_unit.actual_unit_urls.count).to eq 2
        end
      end
      context 'SupplierUrlを確認' do
        context 'supplier_urlがない場合' do
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(1).to(3)
          end
          it 'このactual_unitに紐づくsupplier_urlは2個' do
            subject
            expect(order.actual_unit.supplier_urls.count).to eq 2
          end
          it 'actual_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(order.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
        context 'supplier_urlがある場合' do
          before { create :supplier_url, org: org, url: 'https://example_A.com/' }
          it 'SupplierUrlが2個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(2).to(3)
          end
          it 'このactual_unitに紐づくsupplier_urlは2個' do
            subject
            expect(order.actual_unit.supplier_urls.count).to eq 2
          end
          it 'actual_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(order.actual_unit.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
      end
    end
  end
end
