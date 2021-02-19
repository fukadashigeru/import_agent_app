require 'rails_helper'

RSpec.describe Supplier::SupplierForm::OptionalUnitForm do
  let(:form) do
    described_class.new(
      ordering_org: org,
      supplier: supplier,
      optional_unit_id: optional_unit_id,
      first_priority: first_priority,
      optional_urls: optional_urls
    )
  end
  let(:org) { create :org, org_type: :ordering_org }
  let(:supplier) { create :supplier, org: org }
  let(:supplier_url) { create :supplier_url, url: url, org: org }
  let(:optional_unit_id) { nil }
  let(:first_priority) { false }
  let(:optional_urls) { [''] }

  def create_optional_unit(org, supplier, urls)
    optional_unit = (create :optional_unit, supplier: supplier)
    urls.each do |url|
      supplier_url = org.supplier_urls.find_by(url: url) || (create :supplier_url, org: org, url: url)
      create :optional_unit_url, supplier_url: supplier_url, optional_unit: optional_unit
    end
    optional_unit
  end

  describe 'Methods' do
    describe 'upsert_or_destroy!' do
      subject { form.upsert_or_destroy! }
      context 'optional_unitが新規登録の場合' do
        let(:optional_urls) { ['https://example_A.com/', 'https://example_B.com/'] }
        context 'OptionalUnitを確認' do
          it do
            expect { subject }.to change { OptionalUnit.count }.by(1)
          end
          it do
            subject
            optional_unit = OptionalUnit.last
            expect(optional_unit.supplier).to eq supplier
          end
        end
        context 'first_priority周りを確認' do
          context '第1候補でない場合' do
            it '第1候補になっていない' do
              subject
              optional_unit = OptionalUnit.last
              expect(supplier.first_priority_unit_id).not_to eq optional_unit
            end
          end
          context '第1候補の場合' do
            let(:first_priority) { true }
            it '第1候補になっている' do
              subject
              optional_unit = OptionalUnit.last
              expect(supplier.first_priority_unit).to eq optional_unit
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが2個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.from(0).to(2)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは2個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 2
          end
        end
        context 'SupplierUrlを確認' do
          context 'supplier_urlがない場合' do
            it 'SupplierUrlが2個増える' do
              expect { subject }.to change { SupplierUrl.count }.from(0).to(2)
            end
            it 'このoptional_unitに紐づくsupplier_urlは2個' do
              subject
              expect(supplier.optional_units.last.supplier_urls.count).to eq 2
            end
            it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
              subject
              expect(supplier.optional_units.last.supplier_urls.map(&:url))
                .to eq ['https://example_A.com/', 'https://example_B.com/']
            end
          end
          context 'supplier_urlがある場合' do
            before { create :supplier_url, org: org, url: 'https://example_A.com/'}
            it 'SupplierUrlが1個増える' do
              expect { subject }.to change { SupplierUrl.count }.from(1).to(2)
            end
            it 'このoptional_unitに紐づくsupplier_urlは2個' do
              subject
              expect(supplier.optional_units.last.supplier_urls.count).to eq 2
            end
            it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
              subject
              expect(supplier.optional_units.last.supplier_urls.map(&:url))
                .to eq ['https://example_A.com/', 'https://example_B.com/']
            end
          end
        end
      end

      context 'optional_unitが更新の場合' do
        let(:optional_unit_id) { @optional_unit.id }
        let(:optional_urls) { ['https://example_A.com/', 'https://example_B.com/'] }

        before { @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/']) }
        context 'OptionalUnitを確認' do
          it 'OptionalUnitが増えない' do
            subject
            expect { subject }.to change { OptionalUnit.count }.by(0)
          end
          it 'OptionalUnitが同一である' do
            subject
            optional_unit = OptionalUnitUrl.last.optional_unit
            expect(optional_unit).to eq @optional_unit
          end
        end
        context 'first_priority周りを確認' do
          context '第1候補でない場合' do
            it '第1候補になっていない' do
              subject
              optional_unit = OptionalUnit.last
              expect(supplier.first_priority_unit_id).not_to eq optional_unit
            end
          end
          context '第1候補の場合' do
            let(:first_priority) { true }
            it '第1候補になっている' do
              subject
              optional_unit = OptionalUnit.last
              expect(supplier.first_priority_unit).to eq optional_unit
            end
          end
        end
        context 'OptionalUnitUrlを確認' do
          it 'OptionalUnitUrlが1個増える' do
            expect { subject }.to change { OptionalUnitUrl.count }.by(1)
          end
          it 'このoptional_unitに紐づくoptional_unit_urlは1個' do
            subject
            expect(supplier.optional_units.last.optional_unit_urls.count).to eq 2
          end
        end
        context 'SupplierUrlを確認' do
          it 'SupplierUrlが1個増える' do
            expect { subject }.to change { SupplierUrl.count }.from(1).to(3)
          end
          it 'このoptional_unitに紐づくsupplier_urlは1個' do
            expect { subject }.to change { @optional_unit.supplier_urls.count }.from(1).to(2)
          end
          it 'optional_unitに紐づくsupplier_urlを厳密に確認' do
            subject
            expect(supplier.optional_units.last.supplier_urls.map(&:url))
              .to eq ['https://example_A.com/', 'https://example_B.com/']
          end
        end
      end

      context 'optional_unit_idはあるがoptional_urlsが空' do
        context '単品商品から削除' do
          let(:optional_unit_id) { @optional_unit.id }
          let(:optional_urls) { [''] }
          before do
            @optional_unit = create_optional_unit(org, supplier, ['https://example_a.com/'])
            supplier.update(first_priority_unit_id: @optional_unit.id)
          end

          context 'OptionalUnitを確認' do
            it 'OptionalUnitが削除されている' do
              subject
              expect(supplier.optional_units).to eq []
            end
          end
          context 'first_priority周りを確認' do
            context '第1候補でない場合' do
              it '第1候補になっていない' do
                subject
                expect(supplier.first_priority_unit).not_to eq @optional_unit
              end
            end
            context '第1候補の場合' do
              let(:first_priority) { true }
              it '第1候補になっていない' do
                expect { subject }.to raise_error '第1優先で選択できません。'
              end
            end
          end
          context 'OptionalUnitUrlを確認' do
            it 'OptionalUnitUrlが1個減る' do
              expect { subject }.to change { OptionalUnitUrl.count }.by(-1)
            end
          end
          context 'SupplierUrlを確認' do
            it 'SupplierUrlが増えない' do
              expect { subject }.to change { SupplierUrl.count }.by(0)
            end
          end
        end
      end
    end

    describe 'supplier_forms' do
      subject { form.supplier_forms }
      context '1つURLがある場合' do
        let(:optional_urls) { ['https://example_A.com/'] }
        it do
          expect(subject.map(&:url)).to eq ['https://example_A.com/']
        end
      end
      context 'URLが無い場合' do
        let(:optional_urls) { [] }
        it do
          expect(subject.map(&:url)).to eq []
        end
      end
    end
  end
end
