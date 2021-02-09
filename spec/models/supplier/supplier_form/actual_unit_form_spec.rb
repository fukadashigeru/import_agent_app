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
  let(:order) { create :order, ordering_org: org, supplier: supplier }
  let(:actual_urls) { [''] }

  def create_actual_unit(order, urls)
    actual_unit = (create :actual_unit, order: order)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :actual_unit_url, supplier_url: supplier_url, actual_unit: actual_unit
    end
    actual_unit
  end

  describe 'save_actual_unit!' do
    subject { form.save_actual_unit! }
    context '単品商品の場合' do
      let(:actual_urls) { ['https://example_1.com/'] }
      context 'actual_unitがない場合' do
        context 'supplier_urlがない場合' do
          it 'supplier_urlが1個増える' do
            expect { subject }.to change { org.supplier_urls.count }.by(1)
          end
          it 'actual_unitが1個増える' do
            expect { subject }.to change { ActualUnitUrl.count }.by(1)
          end
        end
        context 'supplier_urlが既にある場合' do
          let!(:supplier_url) { create :supplier_url, url: actual_urls.first, org: org }
          it 'supplier_urlが増えない' do
            expect { subject }.to change { org.supplier_urls.count }.by(0)
          end
          it 'actual_unit_urlが1個増える' do
            expect { subject }.to change { ActualUnitUrl.count }.by(1)
          end
        end
      end

      context 'actual_unitがある場合' do
        context '元々単品商品の場合' do
          before { create_actual_unit(order, ['https://example_a.com/']) }
          context 'supplier_urlがない場合' do
            it 'supplier_urlが1個増える' do
              expect { subject }.to change { org.supplier_urls.count }.by(1)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'supplier_url' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
          context 'supplier_urlが既にある場合' do
            let!(:supplier_url) { create :supplier_url, url: actual_urls.first, org: org }
            it 'supplier_urlが増えない' do
              expect { subject }.to change { org.supplier_urls.count }.by(0)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'supplier_urlを確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end

        context '元はセット商品の場合' do
          before { create_actual_unit(order, ['https://example_a.com/', 'https://example_b.com/']) }
          context 'supplier_urlがない場合' do
            it 'supplier_urlが1個増える' do
              expect { subject }.to change { org.supplier_urls.count }.from(2).to(3)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.from(2).to(1)
            end
            it 'supplier_url' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
          context 'supplier_urlが既にある場合' do
            let!(:supplier_url) { create :supplier_url, url: actual_urls.first, org: org }
            it 'supplier_urlが増えない' do
              expect { subject }.to change { org.supplier_urls.count }.by(0)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.from(2).to(1)
            end
            it 'supplier_urlを確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url)).to eq ['https://example_1.com/']
            end
          end
        end
      end
    end

    context 'セット商品の場合' do
      let(:actual_urls) { ['https://example_1.com/', 'https://example_2.com/'] }
      context 'actual_unitがない場合' do
        context 'supplier_urlがない場合' do
          it 'supplier_urlが2個増える' do
            expect { subject }.to change { org.supplier_urls.count }.by(2)
          end
          it 'actual_unitが1個増える' do
            expect { subject }.to change { ActualUnit.count }.from(0).to(1)
          end
          it 'actual_unit_urlが2個増える' do
            expect { subject }.to change { ActualUnitUrl.count }.from(0).to(2)
          end
        end
        context 'supplier_urlが既にある場合' do
          before do
            create :supplier_url, url: actual_urls.first, org: org
            create :supplier_url, url: actual_urls.second, org: org
          end
          it 'supplier_urlが増えない' do
            expect { subject }.to change { org.supplier_urls.count }.by(0)
          end
          it 'actual_unit_urlが1個増える' do
            expect { subject }.to change { ActualUnitUrl.count }.by(2)
          end
        end
      end

      context 'actual_unitがある場合' do
        context '元は単品商品の場合' do
          before { create_actual_unit(order, ['https://example_a.com/']) }
          context 'supplier_urlがない場合' do
            it 'supplier_urlが1個増える' do
              expect { subject }.to change { org.supplier_urls.count }.by(2)
            end
            it 'actual_unit_urlは1個増える' do
              expect { subject }.to change { ActualUnitUrl.count }.from(1).to(2)
            end
            it 'supplier_urlを確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_1.com/', 'https://example_2.com/']
            end
          end
          context 'supplier_urlが既にある場合' do
            before do
              create :supplier_url, url: actual_urls.first, org: org
              create :supplier_url, url: actual_urls.second, org: org
            end
            it 'supplier_urlが増えない' do
              expect { subject }.to change { org.supplier_urls.count }.by(0)
            end
            it 'actual_unit_urlは1個増える' do
              expect { subject }.to change { ActualUnitUrl.count }.from(1).to(2)
            end
            it 'supplier_urlで確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_1.com/', 'https://example_2.com/']
            end
          end
        end

        context '元々セット商品の場合' do
          before { create_actual_unit(order, ['https://example_a.com/', 'https://example_b.com/']) }
          context 'supplier_urlがない場合' do
            it 'supplier_urlが1個増える' do
              expect { subject }.to change { org.supplier_urls.count }.by(2)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'supplier_urlを確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_1.com/', 'https://example_2.com/']
            end
          end
          context 'supplier_urlが既にある場合' do
            before do
              create :supplier_url, url: actual_urls.first, org: org
              create :supplier_url, url: actual_urls.second, org: org
            end
            it 'supplier_urlが増えない' do
              expect { subject }.to change { org.supplier_urls.count }.by(0)
            end
            it 'actual_unit_urlは増えない' do
              expect { subject }.to change { ActualUnitUrl.count }.by(0)
            end
            it 'supplier_urlで確認' do
              subject
              expect(order.actual_unit.supplier_urls.map(&:url))
                .to eq ['https://example_1.com/', 'https://example_2.com/']
            end
          end
        end
      end
    end
  end
end
